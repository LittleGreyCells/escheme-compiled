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
#include "core/format.hxx"
#include "core/dict.hxx"

#define BCE_CHECK
#undef BCE_CHECK

namespace escheme
{

////////////////////////////////////////////////////
//
//           Byte Code Evaluator (BCE)
//
///////////////////////////////////////////////////

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
   const SEXPR* sv;
   const BYTE* bv;
public:
   BCODE( SEXPR code ) :
      sv( getvectordata(code_getsexprs(code) ) ),
      bv( getbvecdata(code_getbcodes(code)) )
   {
      // empty
   }
   auto operator[]( int index ) const { return bv[index]; }
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

#ifdef BCE_CHECK
   const BCODE bcode( guard(unev, codep) );
#else
   const BCODE bcode( unev );
#endif
   
   while ( true )
   {
      const OpCodes op = (OpCodes)bcode[pc++];

      switch ( op )
      {
	 case OP_SAVE_VAL:  
	    save( val ); 
	    break;

	 case OP_RESTORE_VAL:  
	    restore( val ); 
	    break;

	 case OP_SAVE_AUX:  
	    save( aux ); 
	    break;

	 case OP_RESTORE_AUX:  
	    restore( aux ); 
	    break;

	 case OP_SAVE_ENV:  
#ifdef BCE_CHECK
	    if ( !anyenvp(env) )
	       ERROR::severe( "save-env: not an environment", env );
#endif
	    save( env ); 
	    break;

	 case OP_RESTORE_ENV:  
	    restore( env );
#ifdef BCE_CHECK
	    if ( !anyenvp(env) )
	       ERROR::severe( "restore-env: not an environment", env );
#endif
	    break;

	 case OP_SAVE_UNEV: 
	    save( unev ); 
	    break;

	 case OP_RESTORE_UNEV: 
	    restore( unev ); 
	    break;

	 case OP_SAVE_EXP:  
	    save( exp ); 
	    break;

	 case OP_RESTORE_EXP:  
	    restore( exp ); 
	    break;
	    
#ifndef NO_INTERP
	 case OP_SAVE_xxxx: 
	    save( cont ); 
	    break;

	 case OP_RESTORE_xxxx: 
	    restore( cont ); 
	    break;
#endif
	    
	 case OP_SAVE_ARGC: 
	    save( argstack.argc ); 
	    break;

	 case OP_RESTORE_ARGC: 
	    restore( argstack.argc ); 
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
	    auto sym = bcode.OBJECT( pc );
	    val = value( sym );
	    if ( val == symbol_unbound )
	       ERROR::severe("symbol is undefined", sym);
	    pc += 1;
	    break;
	 }

	 case OP_GDEF:
	 {
	    auto sym = bcode.OBJECT( pc );
	    set( sym, val );
	    pc += 1;
	    break;
	 }

	 case OP_GSET:
	 {
	    auto sym = bcode.OBJECT( pc );
	    if ( value(sym) == symbol_unbound )
	       ERROR::severe("symbol is undefined", sym);
	    set( sym, val );
	    pc += 1;
	    break;
	 }

	 case OP_MODULE:
	 {
	    env = MEMORY::module();
	    break;
	 }

	 case OP_MDEF:
	 {
	    auto sym = bcode.OBJECT( pc );
	    auto mod = guard( env, modulep );
	    auto dict = guard( module_getdict(mod), dictp );
	    dict_set( dict, sym, val );
	    pc += 1;
	    break;
	 }

	 case OP_MREF:
	 {
	    int d = bcode[pc];
	    auto e = env;
	    while (d-- > 0)
	       e = guard(getenvbase(e), envp);
	    guard( e, modulep );
	    auto dict = guard( module_getdict(e), dictp );
	    val = dict_ref( dict, bcode.OBJECT(pc+1) );
	    pc += 2;
	    break;
	 }

	 case OP_MSET:
	 {
	    int d = bcode[pc];
	    auto e = env;
	    while (d-- > 0)
	       e = guard(getenvbase(e), envp);
	    guard( e, modulep );
	    auto dict = guard( module_getdict(e), dictp );
	    dict_set( dict, bcode.OBJECT(pc+1), val );
	    pc += 2;
	    break;
	 }

	 case OP_FREF:
	 {
	    int d = bcode[pc];
#ifdef BCE_CHECK
	    auto e = guard(env, envp);
#else
	    auto e = env;
#endif
	    while (d-- > 0)
#ifdef BCE_CHECK
	       e = guard(getenvbase(e), envp);
#else
	       e = getenvbase(e);
#endif
	    val = frameref( getenvframe(e), bcode[pc+1] );
	    pc += 2;
	    break;
	 }

	 case OP_FSET:
	 {
	    // op, env-depth, frame-index, [val], [env]
	    //     +0         +1 
	    int d = bcode[pc];
#ifdef BCE_CHECK
	    auto e = guard(env, envp);
#else
	    auto e = env;
#endif
	    while (d-- > 0)
#ifdef BCE_CHECK
	       e = guard(getenvbase(e), envp);
#else
	       e = getenvbase(e);
#endif
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
	    save( argstack.argc );
	    save( MEMORY::cons(null, null) );    // val == (())
	    break;
	 }

	 case OP_MAP_APPLY:
	 {
	    if ( nullp(argstack.top()) )
	    {
	       // done
	       restore( val );            // val == (<list> . <last>)
	       val = car(val);                // val == <list>
	       restore( argstack.argc );
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
		   const auto arg = argstack[p+i];
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
	    const auto x = MEMORY::cons(val, null);
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
	    if ( argstack.argc < 2 )
	       ERROR::severe( "for-each requires two or more arguments" );
	    save( argstack.argc );
	    save( null );               // val == ()
	    break;
	 }

	 case OP_FOR_APPLY:
	 {
	    if ( nullp(argstack.top()) )
	    {
	       // done
	       restore( val );         // val == ()
	       restore( argstack.argc );
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
		   const auto arg = argstack[p+i];
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
		  val = getprimfunc(val)();
		  argstack.removeargc();
		  RESTORE_BCE_REGISTERS();
		  goto start_bceval;
	       }

	       case n_closure:
	       {
		  env = extend_env_fun(val);
		  unev = getclosurecode(val);
#ifdef NO_INTERP
		  pc = 0;
		  goto start_bceval;
#else
		  if ( _codep(unev) )
		  {
		     pc = 0;
		     goto start_bceval;
		  }
		  else
		  {
		     save( EVAL_RETURN );
		     next = EVAL_SEQUENCE;
		     return;
		  }
#endif
	       }

	       case n_apply:
	       {
		  ArgstackIterator iter;
		  val = iter.getarg();
		  auto args = guard(iter.getlast(), listp);
		  argstack.removeargc();
		  for ( ; anyp(args); args = cdr(args) )
		     argstack.push(car(args));
		  goto start_apply_cont;
	       }

	       case n_eval:
	       {
		  ArgstackIterator iter;
		  exp = iter.getarg();
		  if ( iter.more() )
		  {
		     env = guard(iter.getlast(), anyenvp);
		  }
		  else
		  {
		     env = null;
		  }
		  argstack.removeargc();

		  // EVAL
#ifdef NO_INTERP
		  unev = exp;
		  pc = 0;
		  goto start_bceval;
#else
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
#endif
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
		  auto ccresult = iter.more() ? iter.getlast() : null;
		  argstack.removeargc();
		  // replace the entire execution context
		  restore_continuation(val);
		  val = ccresult;                                       // now assign val
		  // determine if the continuation should resume here or in the interpereter
#ifdef NO_INTERP
		  RESTORE_BCE_REGISTERS();
		  goto start_bceval;
#else
		  if ( _codep( regstack.top() ) )
		  {
		     RESTORE_BCE_REGISTERS();
		     goto start_bceval;
		  }
		  else
		  {
		     restore( cont );
		     next = cont;
		     return;
		  }
#endif
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
		  auto promise = guard(iter.getlast(), promisep);
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
		     save( promise );
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
	    auto promise = guard( regstack.pop(), promisep );
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
#ifdef BCE_CHECK
	    auto e = guard( regstack.top(), envp );
#else
	    auto e = regstack.top();
#endif
	    const unsigned index = bcode[pc];
#ifdef BCE_CHECK
	    if ( index < getframenslots(getenvframe(e)) )
	       frameset( getenvframe(e), index, val );
	    else
	       ERROR::severe( "eset: index out of bounds", e, MEMORY::fixnum(index) );
#else
	    frameset( getenvframe(e), index, val );
#endif
	    pc += 1;
	    break;
	 }

#ifndef NO_INTERP
	 case OP_RTE:
	 {
	    // op
	    restore(cont);
	    next = cont;
	    return;
	 }
#endif	 
	 case OP_RTC:
	 {
	    // op
	    return;
	 }
	 
	 default:
	 {
	    ERROR::severe( format( "unknown opcode: op=%d, pc=%d", (int)op, pc ).c_str(), unev );
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
