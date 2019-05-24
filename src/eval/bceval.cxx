#include "eval.hxx"
#include "code.hxx"

#include "core/sexpr.hxx"
#include "core/error.hxx"
#include "core/argstack.hxx"
#include "core/regstack.hxx"
#include "core/intstack.hxx"
#include "core/memory.hxx"
#include "core/funtab.hxx"

////////////////////////////////////////////////////
//
//           Byte Code Evaluator (BCE)
//
///////////////////////////////////////////////////

bool bce_trace_switch = true;

#define TRACEVM
#undef TRACEVM
#ifdef TRACEVM
#define TRACE( code ) if (bce_trace_switch) { code; };
#else
#define TRACE( code )
#endif

enum EvalSexprRegisters
{
   ER_VAL,
   ER_AUX,
   ER_ENV,
   ER_UNEV,
   ER_EXP,
};

const char* regnames[] = 
{ 
   "val", 
   "aux", 
   "env", 
   "unev", 
   "exp",
};

//
// (*regs[<spec>]) = <value>
//
SEXPR* regs[] =
{
   &EVAL::val,
   &EVAL::aux,
   &EVAL::env,
   &EVAL::unev,
   &EVAL::exp,
};

//
// Wrap the bcodes rather than save a ref to the underlying data.
// In future object caching schemes the underlying data will be relocated.
//

class BCODE
{
   SEXPR bcodes;
public:
   BCODE( SEXPR bcodes ) : bcodes(bcodes) {}
   BYTE operator[]( int index ) const { return getbvecdata(bcodes)[index]; }
};

#define REGISTER(index) (*regs[bcode[(index)]])
#define OBJECT(index)   vectorref( sexprs, bcode[(index)] )
#define REGNAME(index)  regnames[bcode[(index)]]
#define GET16(index)    (bcode[(index)] + (bcode[(index)+1] << 8))

#define FALSEP(x) ((x) == null) || ((x) == symbol_false)
#define TRUEP(x)  (!(FALSEP(x)))

void EVAL::bceval()
{
  start_bceval:

   guard( unev, codep );

   bool testresult = false;
   
   const auto sexprs = code_getsexprs( unev );
   const BCODE bcode( code_getbcodes( unev ) );
   
   while ( true )
   {
      TRACE( printf( "trace( pc=%d ): ", pc ) );

      const OpCodes op = (OpCodes)bcode[pc++];

      switch ( op )
      {
	 case OP_SAVE_VAL:  
	    TRACE( printf( "save-val\n" ) );
	    save_reg( val ); 
	    break;

	 case OP_RESTORE_VAL:  
	    TRACE( printf( "restore-val\n" ) );
	    restore_reg( val ); 
	    break;

	 case OP_SAVE_AUX:  
	    TRACE( printf( "save-aux\n" ) );
	    save_reg( aux ); 
	    break;

	 case OP_RESTORE_AUX:  
	    TRACE( printf( "restore-aux\n" ) );
	    restore_reg( aux ); 
	    break;

	 case OP_SAVE_ENV:  
	    TRACE( printf( "save-env\n" ) );
	    if ( !(nullp(env) || envp(env)) )
	       ERROR::severe( "save-env: not an environment", env );
	    save_reg( env ); 
	    break;

	 case OP_RESTORE_ENV:  
	    TRACE( printf( "restore-env\n" ) );
	    restore_reg( env );
	    if ( !(nullp(env) || envp(env)) )
	       ERROR::severe( "restore-env: not an environment", env );
	    break;

	 case OP_SAVE_UNEV: 
	    TRACE( printf( "save-unev\n" ) );
	    save_reg( unev ); 
	    break;

	 case OP_RESTORE_UNEV: 
	    TRACE( printf( "restore-unev\n" ) );
	    restore_reg( unev ); 
	    break;

	 case OP_SAVE_EXP:  
	    TRACE( printf( "save-exp\n" ) );
	    save_reg( exp ); 
	    break;

	 case OP_RESTORE_EXP:  
	    TRACE( printf( "restore-exp\n" ) );
	    restore_reg( exp ); 
	    break;

	 case OP_SAVE_xxxx: 
	    TRACE( printf( "save-xxxx\n" ) );
	    save_evs( cont ); 
	    break;

	 case OP_RESTORE_xxxx: 
	    TRACE( printf( "restore-xxxx\n" ) );
	    restore_evs( cont ); 
	    break;

	 case OP_SAVE_ARGC: 
	    TRACE( printf( "save-argc\n" ) );
	    save_int( argstack.argc ); 
	    break;

	 case OP_RESTORE_ARGC: 
	    TRACE( printf( "restore-argc\n" ) );
	    restore_int( argstack.argc ); 
	    break;

	 case OP_ZERO_ARGC: 
	    TRACE( printf( "zero-argc\n" ) );
	    argstack.argc = 0; 
	    break;

	 case OP_PUSH_ARG:  
	    TRACE( printf( "push-arg\n" ) );
	    argstack.push( val ); 
	    break;

	 case OP_POP_ARGS:  
	    TRACE( printf( "pop-args\n" ) );
	    argstack.removeargc(); 
	    break;

#define OP_ASSIGN_REG_CODE()\
	    val = REGISTER( pc );\
	    pc += 1;

	 case OP_ASSIGN_REG:
	    OP_ASSIGN_REG_CODE();
	    break;

	 case OP_ASSIGN_REG_ARG:
	    OP_ASSIGN_REG_CODE();
	    argstack.push( val ); 
	    break;

	 case OP_ASSIGN_REG_APPLY:
	    OP_ASSIGN_REG_CODE();
	    goto start_apply;

	 case OP_ASSIGN_REG_APPLYC:
	    OP_ASSIGN_REG_CODE();
	    goto start_apply_cont;

#define OP_ASSIGN_OBJ_CODE()\
	    val = OBJECT( pc );\
	    pc += 1;\

	 case OP_ASSIGN_OBJ:
	    OP_ASSIGN_OBJ_CODE();
	    break;

	 case OP_ASSIGN_OBJ_ARG:
	    OP_ASSIGN_OBJ_CODE();
	    argstack.push( val ); 
	    break;

	 case OP_ASSIGN_OBJ_APPLY:
	    OP_ASSIGN_OBJ_CODE();
	    goto start_apply;

	 case OP_ASSIGN_OBJ_APPLYC:
	    OP_ASSIGN_OBJ_CODE();
	    goto start_apply_cont;

#define OP_GREF_CODE()\
	    {\
	       SEXPR sym = OBJECT( pc );\
	       val = value( sym );\
	       if (val == SYMTAB::symbol_unbound)\
		  ERROR::severe("symbol is unbound", sym);\
	       pc += 1;\
	    }

	 case OP_GREF:
	    OP_GREF_CODE();
	    break;

	 case OP_GREF_ARG:
	    OP_GREF_CODE();
	    argstack.push( val ); 
	    break;

	 case OP_GREF_APPLY:
	    OP_GREF_CODE();
	    goto start_apply;

	 case OP_GREF_APPLYC:
	    OP_GREF_CODE();
	    goto start_apply_cont;

	 case OP_GSET:
	 {
	    set( OBJECT( pc ), val );
	    pc += 1;
	    break;
	 }

#define OP_FREF_CODE()\
	 {\
	    int d = bcode[pc];\
	    SEXPR e = guard(env, envp);\
	    while (d-- > 0)\
	       e = guard(getenvbase(e), envp);\
	    if ( nullp(e) )\
	       ERROR::severe( "OP_FREF: null env", e );\
	    if ( getenvframe(e) == nullptr )\
	       ERROR::severe( "OP_FREF: empty frame", e );\
	    val = frameref( getenvframe(e), bcode[pc+1] );\
	    pc += 2;\
	 }

	 case OP_FREF:
	    OP_FREF_CODE();
	    break;

	 case OP_FREF_ARG:
	    OP_FREF_CODE();
	    argstack.push( val ); 
	    break;

	 case OP_FREF_APPLY:
	    OP_FREF_CODE();
	    goto start_apply;

	 case OP_FREF_APPLYC:
	    OP_FREF_CODE();
	    goto start_apply_cont;

	 case OP_FSET:
	 {
	    TRACE( printf( "fset %d,%d\n", bcode[pc], bcode[pc+1] ) );
	    // op, env-depth, frame-index, [val], [env]
	    //     +0         +1 
	    int d = bcode[pc];
	    SEXPR e = guard(env, envp);
	    while (d-- > 0)
	       e = guard(getenvbase(e), envp);
	    if ( nullp(e) )
	       ERROR::severe( "OP_FSET: null env", e );
	    if ( getenvframe(e) == nullptr )
	       ERROR::severe( "OP_FSET: empty frame", e );
	    frameset( getenvframe(e), bcode[pc+1], val );
	    pc += 2;
	    break;
	 }

#define OP_GET_ACCESS_CODE()\
	    val = lookup( OBJECT( pc ), val );\
	    pc += 1;

	 case OP_GET_ACCESS:
	    OP_GET_ACCESS_CODE();
	    break;

	 case OP_GET_ACCESS_ARG:
	    OP_GET_ACCESS_CODE();
	    argstack.push( val ); 
	    break;

	 case OP_GET_ACCESS_APPLY:
	    OP_GET_ACCESS_CODE();
	    goto start_apply;

	 case OP_GET_ACCESS_APPLYC:
	    OP_GET_ACCESS_CODE();
	    goto start_apply_cont;

	 case OP_SET_ACCESS:
	 {
	    TRACE( printf( "set-access obj[%d]\n", bcode[pc] ) );
	    // op, [val], sym(SVI), [val], [exp/env2]
	    //            +0
	    set_variable_value( OBJECT( pc ), val, exp );
	    pc += 1;
	    break;
	 }

	 case OP_LAMBDA:
	 {
	    TRACE( printf( "make-closure obj[%d]\n", bcode[pc] ) );
	    // op, [val], bcode(CVI), params(CVI), num, rest, [env]
	    //            +0          +1           +2   +3
	    val = MEMORY::closure( OBJECT( pc ), env );
	    setclosurevars( val, OBJECT( pc+1 ) );
	    setclosurenumv( val, bcode[pc+2] );
	    setclosurerargs( val, bcode[pc+3] ? true : false );
	    pc += 4;
	    break;
	 }

	 case OP_DELAY:
	 {
	    TRACE( printf( "make-delay obj[%d]\n", bcode[pc] ) );
	    // op, [val], bcode(CVI)
	    //            +0 
	    val = MEMORY::promise( OBJECT( pc ) );
	    pc += 1;
	    break;
	 }

	 // map

	 case OP_MAP_INIT:
	 {
	    TRACE( printf( "map-init\n" ) );
	    if (argstack.argc < 2)
	       ERROR::severe( "map requires two or more arguments" );   
	    save_int( argstack.argc );
	    save_reg( MEMORY::cons(null, null) );    // val == (())
	    break;
	 }

	 case OP_MAP_APPLY:
	 {
	    TRACE( printf( "map-apply\n" ) );
	    if ( nullp(argstack.top()) )
	    {
	       // done
	       restore_reg( val );            // val == (<list> . <last>)
	       val = car(val);                // val == <list>
	       restore_int( argstack.argc );
	       argstack.removeargc();
	       pc += 2;
	       // pc -> OP_GOTO_CONT
	    }
	    else
	    {
	       // setup an application
	       const int argc = intstack.top();
	       const int p = argstack.gettop() - argc + 1;
	       val = argstack[p];             // FUN
	       argstack.argc = 0;
	       for ( int i = 1; i < argc; ++i )
	       {
		   const SEXPR arg = argstack[p+i];
		   argstack.push( car(arg) );
		   argstack[p+i] = cdr(arg);
	       }
               // pc -> OP_APPLY
	    }
	    break;
	 }

	 case OP_MAP_RESULT:
	 {
	    TRACE( printf( "map-result\n" ) );
	    // result is in regstack[top]
	    SEXPR x = MEMORY::cons(val, null);
	    const int top = regstack.gettop();
	    if ( nullp(car(regstack[top])) )
	    {
	       // val == (() . ())
	       setcar( regstack[top], x );
	       setcdr( regstack[top], x );
	       // val == (<firstpair> . <firstpair>)
	    }
	    else
	    {
	       // val == ((...<lastpair>) . <lastpair>)
	       setcdr( getcdr(regstack[top]), x );
	       setcdr( regstack[top], x );
	    }
	    pc -= 3;
	    // pc -> OP_MAP_APPLY
	    break;
	 }

	 // for-each

	 case OP_FOR_INIT:
	 {
	    TRACE( printf( "for-init\n" ) );
	    if (argstack.argc < 2)
	       ERROR::severe( "for-each requires two or more arguments" );
	    save_int( argstack.argc );
	    save_reg( null );               // val == ()
	    break;
	 }

	 case OP_FOR_APPLY:
	 {
	    TRACE( printf( "for-apply\n" ) );
	    if ( nullp(argstack.top()) )
	    {
	       // done
	       restore_reg( val );         // val == ()
	       restore_int( argstack.argc );
	       argstack.removeargc();
	       pc += 2;
	       // pc -> OP_GOTO_CONT
	    }
	    else
	    {
	       // setup an application
	       const int argc = intstack.top();
	       const int p = argstack.gettop() - argc + 1;
	       val = argstack[p];             // FUN
	       argstack.argc = 0;
	       for ( int i = 1; i < argc; ++i )
	       {
		   const SEXPR arg = argstack[p+i];
		   argstack.push( car(arg) );
		   argstack[p+i] = cdr(arg);
	       }
	       // pc -> OP_APPLY
	    }
	    break;
	 }

	 case OP_FOR_RESULT:
	 {
	    TRACE( printf( "for-result\n" ) );
	    // result is in regstack[top]
	    pc -= 3;
	    // pc -> OP_FOR_APPLY
	    break;
	 }

	 //
	 // application
	 //
	 //   apply        { saves a partial continuation }
	 //   apply-cont   { performs substance of application }
	 //

	 case OP_APPLY:
	 {
	   start_apply:

	    if ( _funcp(val) )
	    {
	       TRACE( printf( "apply {prim [%s]}\n", FUNTAB::funname(getfunc(val)) ) );
	       val = getfunc(val)();
	       argstack.removeargc();
	       break;
	    }
	    else
	    {
	       TRACE( printf( "[push-cont] " ) );
	       // prepare the return
	       SAVE_BCE_REGISTERS();
	       // fallthru
	    }
	 }

	 case OP_APPLY_CONT:
	 {
	    // op
	    // apply function and return to the current continuation
	    //
	   start_apply_cont:

	    switch ( nodekind(val) )
	    {
	       case n_func:
	       {
		  TRACE( printf( "apply {prim [%s]}\n", FUNTAB::funname(getfunc(val)) ) );
		  // call the primitive directly
		  val = getfunc(val)();        // was getfunc(fun)
		  argstack.removeargc();

		  RESTORE_BCE_REGISTERS();
		  goto start_bceval;
	       }

	       case n_closure:
	       {
		  TRACE( printf( "apply {closure: %p}\n", val ) );	
  
		  env = extend_env_fun(val);
		  unev = getclosurecode(val);

		  if ( _codep(unev) )
		  {
		     pc = 0;
		     goto start_bceval;
		  }
		  else
		  {
		     save_evs( EVAL_RETURN );
		     next = EVAL_SEQUENCE;
		     return;
		  }
	       }

	       case n_apply:
	       {
		  TRACE( printf( "apply {apply}\n" ) );
		  ArgstackIterator iter;
		  val = iter.getarg();
		  SEXPR args = guard(iter.getlast(), listp);
		  argstack.removeargc();
		  for (; anyp(args); args = cdr(args))
		     argstack.push(car(args));
		  goto start_apply_cont;
	       }

	       case n_eval:
	       {
		  TRACE( printf( "apply {eval}\n" ) );
		  ArgstackIterator iter;
		  exp = iter.getarg();
		  if (iter.more())
		  {
		     env = iter.getlast();
		     if (anyp(env))
			guard(env, envp); 
		  }
		  else
		  {
		     env = theGlobalEnv;
		  }
		  argstack.removeargc();

		  // EVAL
		  if ( _codep(exp) )
		  {
		     unev = exp;
		     pc = 0;
		     goto start_bceval;
		  }
		  else
		  {
		     // have interpreter evaluate
		     cont = EVAL_RETURN;
		     next = EVAL_DISPATCH;
		     return;
		  }
	       }

	       case n_callcc:
	       {
		  TRACE( printf( "apply {callcc}\n" ) );
		  ArgstackIterator iter;
		  val = guard(iter.getlast(), closurep);
		  argstack.removeargc();
		  // create and pass the continuation to the argument function
		  argstack.push( create_continuation() );
		  goto start_apply_cont;
	       }

	       case n_continuation:
	       {
		  TRACE( printf( "apply {continuation: %p}\n", val ) );
		  ArgstackIterator iter;
		  SEXPR ccresult = iter.more() ? iter.getlast() : null;
		  argstack.removeargc();

		  // replace the entire execution context
		  restore_continuation(val);
		  val = ccresult;                                       // now assign val

		  // determine if the continuation should resume here or in the interpereter
		  if ( _codep( regstack.top() ) )
		  {
		     RESTORE_BCE_REGISTERS();
		     goto start_bceval;
		  }
		  else
		  {
		     restore_evs( cont );
		     next = cont;
		     return;
		  }
	       }

	       case n_map:
	       {
		  TRACE( printf( "apply {map}\n" ) );
		  unev = map_code;
		  pc = 0;
		  goto start_bceval;
	       }

	       case n_foreach:
	       {
		  TRACE( printf( "apply {foreach}\n" ) );
		  unev = for_code;
		  pc = 0;
		  goto start_bceval;
	       }

	       case n_force:
	       {
		  TRACE( printf( "apply {force}\n" ) );
		  ArgstackIterator iter;
		  SEXPR promise = guard(iter.getlast(), promisep);
		  argstack.removeargc();
		  if ( nullp(promise_getexp(promise)) )
		  {
		     // already forced
		     val = promise_getval(promise);
		     RESTORE_BCE_REGISTERS();
		     goto start_bceval;
		  }
		  else
		  {
		     // force the evaluation of the promise...
		     save_reg( promise );
		     unev = fep_code;
		     pc = 0;
		     SAVE_BCE_REGISTERS();
		     unev = promise_getexp(promise);
		     pc = 0;
		     goto start_bceval;
		  }
	       }

	       default:
	       {
		  ERROR::severe( "[bce] not a callable", val );
		  return;
	       }
	    }
	    // we never get here
	    break;
	 }

	 case OP_FORCE_VALUE:
	 {
	    TRACE( printf( "force-value\n" ) );
	    // cache and return the forced value
	    // result is in val
	    // promise is on regstack.top()
	    SEXPR promise = guard( regstack.pop(), promisep );
	    promise_setexp( promise, null );
	    promise_setval( promise, val );
	    break;
	 }

	 case OP_TEST_TRUE:
	 {
	    TRACE( printf( "test-true\n" ) );
	    // op, [result], [val]
	    testresult = TRUEP(val);
	    break;
	 }

	 case OP_TEST_FALSE:
	 {
	    TRACE( printf( "test-false\n" ) );
	    // op, [result], [val]
	    testresult = FALSEP(val);
	    break;
	 }

	 case OP_BRANCH:
	 {
	    TRACE( printf( "branch %d\n", GET16(pc) ) );
	    // op, bcode-index
	    //         +0
	    if ( testresult )
	       pc = GET16(pc);
	    else
	       pc += 2;
	    break;
	 }

	 case OP_GOTO:
	 {
	    TRACE( printf( "goto %d\n", GET16(pc) ) );
	    // op, bcode-index
	    //         +0
	    pc = GET16(pc);
	    break;
	 }

	 case OP_BRANCH_CONT:
	 {
	    TRACE( printf( "branch-cont %d\n", cont ) );
	    // op
	    if ( testresult )
	    {
	       RESTORE_BCE_REGISTERS();
	       goto start_bceval;
	    }
	    break;
	 }

	 case OP_GOTO_CONT:
	 {
	    TRACE( printf( "goto-cont %d\n", cont ) );
	    // op
	    RESTORE_BCE_REGISTERS();
	    goto start_bceval;
	 }

	 case OP_EXTEND_ENV:
	 {
	    TRACE( printf( "extend-env\n" ) );
	    // op, reg, nvars, vars(SVI), [env] (4b)
	    //     +0   +1     +2
	    REGISTER( pc ) = MEMORY::environment( bcode[pc+1], OBJECT( pc+2 ), env );
	    pc += 3;
	    break;
	 }

	 case OP_ESET:
	 {
	    TRACE( printf( "eset\n" ) );
	    // op, index, [val]                 (2b)
	    //     +0
	    SEXPR e = guard( regstack.top(), envp );
	    const unsigned index = bcode[pc];
	    if ( index < getframenslots(getenvframe(e)) )
	       frameset( getenvframe(e), index, val );
	    else
	       ERROR::severe( "eset: index out of bounds", e, MEMORY::fixnum(index) );
	    pc += 1;
	    break;
	 }

	 case OP_RTE:
	 {
	    TRACE( printf( "rte\n" ) );
	    // op
	    restore_evs(cont);
	    next = cont;
	    return;
	 }
	 
	 default:
	 {
	    char message[80];
	    SPRINTF( message, "unknown opcode: op=%d, pc=%d", op, pc );
	    ERROR::severe( message, unev );
	    break;
	 }
      }
   }
}
