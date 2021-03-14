#include "eval.hxx"
#include "code.hxx"

#include "core/sexpr.hxx"
#include "core/error.hxx"
#include "core/argstack.hxx"
#include "core/regstack.hxx"
#include "core/intstack.hxx"
#include "core/memory.hxx"
#include "core/funtab.hxx"
#include "core/symtab.hxx"

namespace escheme
{

////////////////////////////////////////////////////
//
//           Byte Code Evaluator (BCE)
//
///////////////////////////////////////////////////

bool bce_trace_switch = true;

enum EvalSexprRegisters
{
   ER_VAL,
   ER_AUX,
   ER_ENV,
   ER_UNEV,
   ER_EXP,
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
// In future object caching schemes the underlying data may be relocated.
//

class BCODE
{
   SEXPR* sv;
   BYTE* bv;
public:
   BCODE( SEXPR code )
   {
      sv = getvectordata(code_getsexprs(code));
      bv = getbvecdata(code_getbcodes(code));
   }
   BYTE operator[]( int index ) const { return bv[index]; }
   auto& REGISTER( int index ) const { return *regs[bv[index]]; }
   auto OBJECT( int index ) const { return sv[bv[index]]; }
   auto GET16( int index ) const { return bv[index] + (bv[index+1] << 8); }
};

//
// BCEVAL
//

void EVAL::bceval()
{
  start_bceval:

   bool testresult = false;

   const BCODE bcode( guard(unev, codep) );
   
   while ( true )
   {
      const OpCodes op = (OpCodes)bcode[pc++];

      switch ( op )
      {
	 case OP_SAVE_VAL:  
	    save_reg( val ); 
	    break;

	 case OP_RESTORE_VAL:  
	    restore_reg( val ); 
	    break;

	 case OP_SAVE_AUX:  
	    save_reg( aux ); 
	    break;

	 case OP_RESTORE_AUX:  
	    restore_reg( aux ); 
	    break;

	 case OP_SAVE_ENV:  
	    if ( !(nullp(env) || envp(env)) )
	       ERROR::severe( "save-env: not an environment", env );
	    save_reg( env ); 
	    break;

	 case OP_RESTORE_ENV:  
	    restore_reg( env );
	    if ( !(nullp(env) || envp(env)) )
	       ERROR::severe( "restore-env: not an environment", env );
	    break;

	 case OP_SAVE_UNEV: 
	    save_reg( unev ); 
	    break;

	 case OP_RESTORE_UNEV: 
	    restore_reg( unev ); 
	    break;

	 case OP_SAVE_EXP:  
	    save_reg( exp ); 
	    break;

	 case OP_RESTORE_EXP:  
	    restore_reg( exp ); 
	    break;

	 case OP_SAVE_xxxx: 
	    save_evs( cont ); 
	    break;

	 case OP_RESTORE_xxxx: 
	    restore_evs( cont ); 
	    break;

	 case OP_SAVE_ARGC: 
	    save_int( argstack.argc ); 
	    break;

	 case OP_RESTORE_ARGC: 
	    restore_int( argstack.argc ); 
	    break;

	 case OP_ZERO_ARGC: 
	    argstack.argc = 0; 
	    break;

	 case OP_PUSH_ARG:  
	    argstack.push( val ); 
	    break;

	 case OP_POP_ARGS:  
	    argstack.removeargc(); 
	    break;

	 case OP_ASSIGN_REG:
	    val = bcode.REGISTER( pc );
	    pc += 1;
	    break;

	 case OP_ASSIGN_OBJ:
	    val = bcode.OBJECT( pc );
	    pc += 1;
	    break;

	 case OP_GREF:
	 {
	    SEXPR sym = bcode.OBJECT( pc );
	    val = value( sym );
	    if (val == symbol_unbound)
	       ERROR::severe("symbol is unbound", sym);
	    pc += 1;
	    break;
	 }

	 case OP_GSET:
	 {
	    set( bcode.OBJECT( pc ), val );
	    pc += 1;
	    break;
	 }

	 case OP_FREF:
	 {
	    int d = bcode[pc];
	    SEXPR e = guard(env, envp);
	    while (d-- > 0)
	       e = guard(getenvbase(e), envp);
	    val = frameref( getenvframe(e), bcode[pc+1] );
	    pc += 2;\
	    break;
	 }

	 case OP_FSET:
	 {
	    // op, env-depth, frame-index, [val], [env]
	    //     +0         +1 
	    int d = bcode[pc];
	    SEXPR e = guard(env, envp);
	    while (d-- > 0)
	       e = guard(getenvbase(e), envp);
	    frameset( getenvframe(e), bcode[pc+1], val );
	    pc += 2;
	    break;
	 }

	 case OP_GET_ACCESS:
            val = lookup( bcode.OBJECT( pc ), val );
            pc += 1;
	    break;

	 case OP_SET_ACCESS:
	 {
	    // op, [val], sym(SVI), [val], [exp/env2]
	    //            +0
	    set_variable_value( bcode.OBJECT( pc ), val, exp );
	    pc += 1;
	    break;
	 }

	 case OP_LAMBDA:
	 {
	    // op, [val], bcode(CVI), params(CVI), num, rest, [env]
	    //            +0          +1           +2   +3
	    val = MEMORY::closure( bcode.OBJECT( pc ), env );
	    setclosurevars( val, bcode.OBJECT( pc+1 ) );
	    setclosurenumv( val, bcode[pc+2] );
	    setclosurerargs( val, bcode[pc+3] ? true : false );
	    pc += 4;
	    break;
	 }

	 case OP_DELAY:
	 {
	    // op, [val], bcode(CVI)
	    //            +0 
	    val = MEMORY::promise( bcode.OBJECT( pc ) );
	    pc += 1;
	    break;
	 }

	 // map

	 case OP_MAP_INIT:
	 {
	    if ( argstack.argc < 2 )
	       ERROR::severe( "map requires two or more arguments" );   
	    save_int( argstack.argc );
	    save_reg( MEMORY::cons(null, null) );    // val == (())
	    break;
	 }

	 case OP_MAP_APPLY:
	 {
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
	    if (argstack.argc < 2)
	       ERROR::severe( "for-each requires two or more arguments" );
	    save_int( argstack.argc );
	    save_reg( null );               // val == ()
	    break;
	 }

	 case OP_FOR_APPLY:
	 {
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
	       val = getprimfunc(val)();
	       argstack.removeargc();
	       break;
	    }
	    else
	    {
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
		  // call the primitive directly
		  val = getprimfunc(val)();        // was getfunc(fun)
		  argstack.removeargc();
		  RESTORE_BCE_REGISTERS();
		  goto start_bceval;
	       }

	       case n_closure:
	       {
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
		  ArgstackIterator iter;
		  exp = iter.getarg();
		  if ( iter.more() )
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
		  ArgstackIterator iter;
		  val = guard(iter.getlast(), closurep);
		  argstack.removeargc();
		  // create and pass the continuation to the argument function
		  argstack.push( create_continuation() );
		  goto start_apply_cont;
	       }

	       case n_continuation:
	       {
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
		  unev = map_code;
		  pc = 0;
		  goto start_bceval;
	       }

	       case n_foreach:
	       {
		  unev = for_code;
		  pc = 0;
		  goto start_bceval;
	       }

	       case n_force:
	       {
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
	    // op, [result], [val]
	    testresult = truep(val);
	    break;
	 }

	 case OP_TEST_FALSE:
	 {
	    // op, [result], [val]
	    testresult = falsep(val);
	    break;
	 }

	 case OP_BRANCH:
	 {
	    // op, bcode-index
	    //         +0
	    if ( testresult )
	       pc = bcode.GET16(pc);
	    else
	       pc += 2;
	    break;
	 }

	 case OP_GOTO:
	 {
	    // op, bcode-index
	    //         +0
	    pc = bcode.GET16(pc);
	    break;
	 }

	 case OP_BRANCH_CONT:
	 {
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
	    // op
	    RESTORE_BCE_REGISTERS();
	    goto start_bceval;
	 }

	 case OP_EXTEND_ENV:
	 {
	    // op, reg, nvars, vars(SVI), [env] (4b)
	    //     +0   +1     +2
	    bcode.REGISTER( pc ) = MEMORY::environment( bcode[pc+1], bcode.OBJECT( pc+2 ), env );
	    pc += 3;
	    break;
	 }

	 case OP_ESET:
	 {
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
	    // op
	    restore_evs(cont);
	    next = cont;
	    return;
	 }
	 
	 case OP_RTC:
	 {
	    // op
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

void EVAL::bceval( SEXPR exp )
{
   unev = exp;
   pc = 0;
   SAVE_RTC();
   bceval();
}

}
