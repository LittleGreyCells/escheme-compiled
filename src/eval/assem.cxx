#include "assem.hxx"

#include <vector>

#include "code.hxx"

#include "core/error.hxx"
#include "core/argstack.hxx"
#include "core/printer.hxx"
#include "core/pio.hxx"
#include "core/memory.hxx"
#include "core/regstack.hxx"
#include "core/symtab.hxx"

//
// instruction set
//
//   <reg> = val | aux | env | unev | exp | cont | argc
//
//   (save <reg>)
//   (restore <reg>)
//   (zero-argc)
//   (push-arg)
//   (pop-args)
//   (assign <reg> (reg <reg>))
//   (assign <reg> (const <value>))
//   (gref [<reg>] <sym>)
//   (gset <sym>)
//   (fref <reg> <depth> <index>) 
//   (fset <depth> <index>)
//   (get-access [<reg>] (const <sym>) [(reg val)])
//   (set-access [<reg>] (const <sym>) [(reg val)] [(reg exp)])
//   (make-closure <reg> <bcodes> <params> <num> <rest>)
//   (apply)
//   (apply-cont)
//   (test-true)
//   (test-false)
//   (branch (label <label>))
//   (branch (reg cont))
//   (goto (label <label>))
//   (goto (reg cont))
//   (map-init)
//   (map-apply)
//   (map-result)
//   (for-init)
//   (for-apply)
//   (for-result)
//   (extend-env <reg> <nvars> <vars>)
//   (eset <index>)
//   (delay <code>)
//   (save-cont (label <label>))
//   <combos>
//   (rte)
//   (done)
//

namespace escheme
{

namespace FUNC
{
   bool eqv( SEXPR e1, SEXPR e2 );
}

static bool verbose = false;

struct OpcodeEntry
{
   OpCodes op;
   int nbytes;
   const char* name;
   SEXPR symbol;
};

static std::vector<OpcodeEntry> optab =
{
   // standard
   { OP_SAVE_VAL,          1, "save-val"     , nullptr }, // op=0
   { OP_SAVE_AUX,          1, "save-aux"     , nullptr }, // op=1
   { OP_SAVE_ENV,          1, "save-env"     , nullptr }, // op=2
   { OP_SAVE_UNEV,         1, "save-unev"    , nullptr }, // op=3
   { OP_SAVE_EXP,          1, "save-exp"     , nullptr }, // op=4
   { OP_SAVE_ARGC,         1, "save-argc"    , nullptr }, // op=5
   { OP_SAVE_xxxx,         1, "save-xxxx"    , nullptr }, // op=6

   { OP_RESTORE_VAL,       1, "restore-val"  , nullptr }, // op=7
   { OP_RESTORE_AUX,       1, "restore-aux"  , nullptr }, // op=8
   { OP_RESTORE_ENV,       1, "restore-env"  , nullptr }, // op=9
   { OP_RESTORE_UNEV,      1, "restore-unev" , nullptr }, // op=10
   { OP_RESTORE_EXP,       1, "restore-exp"  , nullptr }, // op=11
   { OP_RESTORE_ARGC,      1, "restore-argc" , nullptr }, // op=12
   { OP_RESTORE_xxxx,      1, "restore-xxxx" , nullptr }, // op=13

   { OP_ZERO_ARGC,         1, "zero-argc"    , nullptr }, // op=14
   { OP_PUSH_ARG,          1, "push-arg"     , nullptr }, // op=15
   { OP_POP_ARGS,          1, "pop-args"     , nullptr }, // op=16
   { OP_ASSIGN_REG,        2, "assign-reg"   , nullptr }, // op=17
   { OP_ASSIGN_OBJ,        2, "assign-obj"   , nullptr }, // op=18
   { OP_GREF,              2, "gref"         , nullptr }, // op=19
   { OP_GSET,              2, "gset"         , nullptr }, // op=20
   { OP_FREF,              3, "fref"         , nullptr }, // op=21
   { OP_FSET,              3, "fset"         , nullptr }, // op=22
   { OP_GET_ACCESS,        2, "get-access"   , nullptr }, // op=23
   { OP_SET_ACCESS,        2, "set-access"   , nullptr }, // op=24
   { OP_LAMBDA,            5, "make-closure" , nullptr }, // op=25
   { OP_APPLY,             1, "apply"        , nullptr }, // op=26
   { OP_APPLY_CONT,        1, "apply-cont"   , nullptr }, // op=27
   { OP_TEST_TRUE,         1, "test-true"    , nullptr }, // op=28
   { OP_TEST_FALSE,        1, "test-false"   , nullptr }, // op=29
   { OP_BRANCH,            3, "branch"       , nullptr }, // op=30
   { OP_BRANCH_CONT,       1, "branch-cont"  , nullptr }, // op=31
   { OP_GOTO,              3, "goto"         , nullptr }, // op=32
   { OP_GOTO_CONT,         1, "goto-cont"    , nullptr }, // op=33
   { OP_MAP_INIT,          1, "map-init"     , nullptr }, // op=34
   { OP_MAP_APPLY,         1, "map-apply"    , nullptr }, // op=35
   { OP_MAP_RESULT,        1, "map-result"   , nullptr }, // op=36
   { OP_FOR_INIT,          1, "for-init"     , nullptr }, // op=37
   { OP_FOR_APPLY,         1, "for-apply"    , nullptr }, // op=38
   { OP_FOR_RESULT,        1, "for-result"   , nullptr }, // op=39
   { OP_EXTEND_ENV,        4, "extend-env"   , nullptr }, // op=40
   { OP_ESET,              2, "eset"         , nullptr }, // op=41
   { OP_DELAY,             2, "delay"        , nullptr }, // op=42
   { OP_FORCE_VALUE,       1, "force-value"  , nullptr }, // op=43

   // combos
   { OP_ASSIGN_REG_ARG,    2, "assign-reg-arg"    , nullptr },
   { OP_ASSIGN_OBJ_ARG,    2, "assign-obj-arg"    , nullptr },
   { OP_GREF_ARG,          2, "gref-arg"          , nullptr },
   { OP_FREF_ARG,          3, "fref-arg"          , nullptr },
   { OP_GET_ACCESS_ARG,    2, "get-access-arg"    , nullptr },
   { OP_ASSIGN_REG_APPLY,  2, "assign-reg-apply"  , nullptr },
   { OP_ASSIGN_OBJ_APPLY,  2, "assign-obj-apply"  , nullptr },
   { OP_GREF_APPLY,        2, "gref-apply"        , nullptr },
   { OP_FREF_APPLY,        3, "fref-apply"        , nullptr },
   { OP_GET_ACCESS_APPLY,  2, "get-access-apply"  , nullptr },
   { OP_ASSIGN_REG_APPLYC, 2, "assign-reg-applyc" , nullptr },
   { OP_ASSIGN_OBJ_APPLYC, 2, "assign-obj-applyc" , nullptr },
   { OP_GREF_APPLYC,       2, "gref-applyc"       , nullptr },
   { OP_FREF_APPLYC,       3, "fref-applyc"       , nullptr },
   { OP_GET_ACCESS_APPLYC, 2, "get-access-applyc" , nullptr },

   // exit(s)
   { OP_RTE,               1, "rte" , nullptr },
   { OP_RTC,               1, "rtc" , nullptr },
};

struct RegisterEntry
{
   const char* name;
   SEXPR symbol;
};

// order of these regtab entries is critical

static std::vector<RegisterEntry> regtab =
{
   { "val"  , nullptr },
   { "aux"  , nullptr },
   { "env"  , nullptr },
   { "unev" , nullptr },
   { "exp"  , nullptr },
   { "argc" , nullptr },
};

static SEXPR symbol_reg;
static SEXPR symbol_const;
static SEXPR symbol_label;

static SEXPR symbol_save;
static SEXPR symbol_restore;
static SEXPR symbol_assign;


static void initialize_symbols()
{
   // initialize optable
   for ( auto& entry : optab )
   {
      entry.symbol = SYMTAB::enter( entry.name );
   }

   // symbols for assembly naming differences
   symbol_save    = SYMTAB::enter( "save" );
   symbol_restore = SYMTAB::enter( "restore" );
   symbol_assign  = SYMTAB::enter( "assign" );

   // initialize register table
   for ( auto& entry : regtab )
   {
      entry.symbol = SYMTAB::enter( entry.name );
   }

   // other symbols
   symbol_reg   = SYMTAB::enter( "reg"   );
   symbol_const = SYMTAB::enter( "const" );
   symbol_label = SYMTAB::enter( "label" );
}

static OpCodes find_op( const SEXPR symbol )
{
   if ( symbol == symbol_save )         return OP_SAVE_VAL;
   else if ( symbol == symbol_restore ) return OP_RESTORE_VAL;
   else if ( symbol == symbol_assign )  return OP_ASSIGN_REG;

   for ( auto& entry : optab )
   {
      if ( symbol == entry.symbol )
	 return entry.op;
   }

   ERROR::severe( "encode -- <opcode> not found", symbol );
   
   // we never get here; return something to quiet the warning
   return OP_SAVE_VAL;
}

static int find_reg( const SEXPR symbol )
{
   for ( int i = 0; i < regtab.size(); i += 1 )
   {
      if ( symbol == regtab[i].symbol )
	 return i;
   }

   ERROR::severe( "encode -- <reg> not found", symbol );
   
   // we never get here; return something to quiet the warning
   return 0;
}

//
// ENCODE
//

struct Assoc
{
   Assoc( SEXPR k, int v ) : key(k), value(v) {} 
   SEXPR key;
   int value;
};

static void append_byte( std::vector<BYTE>& bv, int byte )
{
   bv.push_back( byte );
}

static unsigned add_sexpr( std::vector<SEXPR>& sv, SEXPR object )
{
   for ( int i = 0; i < sv.size(); i += 1 )
   {
      if ( FUNC::eqv( sv[i], object ) )
	 return i;
   }
   const unsigned index = sv.size();
   sv.push_back( object );
   return index;
}

static void add_assoc( std::vector<Assoc>& assoc, SEXPR key, int value )
{
   assoc.push_back( Assoc(key, value) );
}

static void make16( std::vector<BYTE>& bv, int target, int value )
{
   const int b1 = value & 0xFF;
   const int b2 = value >> 8;
   bv[target  ] = b1;
   bv[target+1] = b2;
}

static void resolve_jumps( std::vector<BYTE>& bv,
			   std::vector<Assoc>& jumps,
			   std::vector<Assoc>& labels )
{
   // jumps need to be resolved with abs locs of labels
   for ( auto& jump : jumps )
   {
      for ( auto& label : labels )
      {
	 // a key can be a symbol or a number
	 if ( FUNC::eqv(jump.key, label.key) )
	 {
	    make16( bv, jump.value, label.value );
	    break;
	 }
      }
   }
}

static SEXPR clone( std::vector<BYTE>& bv )
{
   SEXPR v = MEMORY::byte_vector( bv.size() );

   for ( int i = 0; i < bv.size(); i += 1 )
      bvecset( v, i, bv[i] );

   return v;
}

static SEXPR clone( std::vector<SEXPR>& sv )
{
   SEXPR v = MEMORY::vector( sv.size() );

   for ( int i = 0; i < sv.size(); i += 1 )
      vectorset( v, i, sv[i] );

   return v;
}


static std::vector<std::vector<SEXPR>*> sv_stack;

static SEXPR encode( SEXPR program )
{
   std::vector<Assoc> jumps;
   std::vector<Assoc> labels;
   std::vector<BYTE> bv;
   std::vector<SEXPR> sv;

   // preserve the sv
   //   there could be code objects contained for nested closures
   sv_stack.push_back( &sv );

#ifdef DO_COMBOS
   // for peep fixups
   int prev_op = 0;
#endif

   while ( !nullp(program) )
   {
      SEXPR x = car(program);

      if ( symbolp(x) || fixnump(x) )
      {
	 add_assoc( labels, x, bv.size() );

#ifdef DO_COMBOS
	 // flush pipe
	 prev_op = 0;
#endif
      }
      else
      {
	 if ( verbose )
	 {
	    PRINTER::print(x);
	    PRINTER::newline();
	 }

	 // encode the instruction
	 const SEXPR opsym = car(x);
	 OpCodes op = find_op( opsym );

	 switch ( op )
	 {
	    case OP_SAVE_VAL:
	    {
	       // (save <reg>)
	       const int reg = find_reg(car(cdr(x)));
	       append_byte( bv, op + reg );
	       break;
	    }

	    case OP_RESTORE_VAL:
	    {
	       // (restore <reg>)
	       const int reg = find_reg(car(cdr(x)));
	       append_byte( bv, op + reg );
	       break;
	    }

	    case OP_ASSIGN_REG:
	    {
	       // (assign <reg> (const <obj>))
	       // (assign <reg> (reg <reg>))
	       const SEXPR source = car(cdr(cdr(x)));

	       if ( car(source) == symbol_reg )
	       {
		  op = OP_ASSIGN_REG;
		  // (reg <reg>)
		  append_byte( bv, op );
		  const int reg = find_reg(car(cdr(source)));
		  append_byte( bv, reg );
	       }
	       else if ( car(source) == symbol_const )
	       {
		  op = OP_ASSIGN_OBJ;
		  // (const <value>))
		  append_byte( bv, op );
		  const SEXPR obj = car(cdr(source));
		  append_byte( bv, add_sexpr( sv, obj ) );
	       }
	       else
	       {
		  ERROR::severe( "unrecognized assign source", source );
	       }
	       break;
	    }

	    case OP_GREF:
	    {
	       // (gref [<reg>] <sym>)
	       //   note: the compiler still embeds the register,
	       //         even though register <val> is the only target
	       append_byte( bv, op );
	       const SEXPR obj = car(cdr(cdr(x)));
	       append_byte( bv, add_sexpr( sv, obj ) );
	       break;
	    }

	    case OP_GSET:
	    {
	       // (gset <sym>) 
	       append_byte( bv, op );
	       const SEXPR obj = car(cdr(x));
	       append_byte( bv, add_sexpr( sv, obj ) );
	       break;
	    }

	    case OP_FREF:
	    {
	       // (fref <reg> <depth> <index>) 
	       append_byte( bv, op );
	       const SEXPR di = cdr(cdr(x));          // (<depth> <index>)
	       append_byte( bv, fixnum(car(di)) );
	       append_byte( bv, fixnum(car(cdr(di))) );
	       break;
	    }

	    case OP_FSET:
	    {
	       // (fset <depth> <index>)
	       append_byte( bv, op );
	       const SEXPR di = cdr(x);               // (<depth> <index>)
	       append_byte( bv, fixnum(car(di)) );
	       append_byte( bv, fixnum(car(cdr(di))) );
	       break;
	    }

	    case OP_GET_ACCESS:
	    {
	       // (get-access <reg> (const <sym>) [(reg val)])
	       //    -register <val> contains the environment
	       //    -register <val> is always the destination
	       append_byte( bv, op );
	       const SEXPR cs = car(cdr(cdr(x)));   // (const <sym>)
	       append_byte( bv, add_sexpr( sv, car(cdr(cs)) ) );
	       break;
	    }

	    case OP_SET_ACCESS:
	    {
	       // (set-access <reg> (const <sym>) [(reg val)] [(reg exp)]) 
	       //    set-access takes some setting up:
	       //    -register <exp> contains the environment
	       //    -register <val> contains the value
	       //    -register <val> is always the destination
	       //    consider:
	       //      (set! (access <sym> <env>) <value>) ==>
	       //        ;; evaluate <env>
	       //        (save val)
	       //        ;; evaluate <value>
	       //        (restore exp)        ;; =<env>
	       //        (set-access val (const <sym>) (reg val) (reg exp))
	       append_byte( bv, op );
	       const SEXPR cs = car(cdr(cdr(x)));   // (const <sym>)
	       append_byte( bv, add_sexpr( sv, car(cdr(cs)) ) );
	       break;
	    }

	    case OP_LAMBDA:
	    {
	       // (make-closure <reg> <bcodes> <params> <num> <rest>)
	       append_byte( bv, op );
	       x = cdr(cdr(x));
	       // x == (<bcodes> <params>...)
	       // encode <bcodes> -- recurse...
	       append_byte( bv, add_sexpr( sv, encode(car(x)) ) );
	       // <params>
	       append_byte( bv, add_sexpr( sv, car(cdr(x)) ) );
	       x = cdr(cdr(x));
	       // x == (<num> <rest>) 
	       append_byte( bv, fixnum(car(x)) );
	       x = car(cdr(x));
	       // x == <rest>  ;; #t | #f
	       append_byte( bv, x == SYMTAB::symbol_true ? 1 : 0 );
	       break;
	    }

	    case OP_DELAY:
	    {
	       // (make-delay <bcodes>)
	       append_byte( bv, op );
	       // encode <bcodes> -- recurse...
	       append_byte( bv, add_sexpr( sv, encode(car(cdr(x))) ) );
	       break;
	    }

	    case OP_BRANCH:
	    {
	       // (branch (label <label>))
	       // (branch (reg cont))
	       const SEXPR target = car(cdr(x));

	       if ( car(target) == symbol_label )
	       {
		  op = OP_BRANCH;
		  // (label <label>)
		  append_byte( bv, op );
		  const SEXPR label = car(cdr(target));
		  add_assoc( jumps, label, bv.size() );
		  // make room for branch location
		  append_byte( bv, 0 );
		  append_byte( bv, 0 );
	       }
	       else
	       {
		  op = OP_BRANCH_CONT;
		  // (reg cont)
		  append_byte( bv, op );
	       }
	       break;
	    }

	    case OP_GOTO:
	    {
	       // (goto (label <label>))
	       // (goto (reg cont))
	       const SEXPR target = car(cdr(x));

	       if ( car(target) == symbol_label )
	       {
		  op = OP_GOTO;
		  // (label <label>)
		  append_byte( bv, op );
		  const SEXPR label = car(cdr(target));
		  add_assoc( jumps, label, bv.size() );
		  // make room for branch location
		  append_byte( bv, 0 );
		  append_byte( bv, 0 );
	       }
	       else
	       {
		  op = OP_GOTO_CONT;
		  // (reg cont)
		  append_byte( bv, op );
	       }
	       break;
	    }

	    case OP_ZERO_ARGC:
	    case OP_POP_ARGS:
	    case OP_TEST_TRUE:
	    case OP_TEST_FALSE:
	    case OP_MAP_INIT:
	    case OP_MAP_APPLY :
	    case OP_MAP_RESULT:
	    case OP_FOR_INIT:
	    case OP_FOR_APPLY:
	    case OP_FOR_RESULT:
	    case OP_FORCE_VALUE:
	    {
 	       append_byte( bv, op );
	       break;
	    }

	    case OP_PUSH_ARG:
	    case OP_APPLY:
	    case OP_APPLY_CONT:
	    {
#ifdef DO_COMBOS
	       // 
	       // simple peep hole optimizations
	       //   two instruction sequences are merged into one
	       //
	       switch ( prev_op )
	       {
		  case OP_ASSIGN_REG:
		  {
		     // convert assign to assign combo (reg)
		     if ( op == OP_PUSH_ARG ) 	op = OP_ASSIGN_REG_ARG;
		     else if ( op == OP_APPLY )	op = OP_ASSIGN_REG_APPLY;
		     else			op = OP_ASSIGN_REG_APPLYC;
		     bv[ bv.size() - optab[prev_op].nbytes ] = op;
		     break;
		  }
		  case OP_ASSIGN_OBJ:
		  {
		     // convert assign to assign combo (obj)
		     if ( op == OP_PUSH_ARG )	op = OP_ASSIGN_OBJ_ARG;
		     else if ( op == OP_APPLY )	op = OP_ASSIGN_OBJ_APPLY;
		     else			op = OP_ASSIGN_OBJ_APPLYC;
		     bv[ bv.size() - optab[prev_op].nbytes ] = op;
		     break;
		  }
		  case OP_GREF:
		  {
		     // convert gref to gref combo
		     if ( op == OP_PUSH_ARG )	op = OP_GREF_ARG;
		     else if ( op == OP_APPLY )	op = OP_GREF_APPLY;
		     else			op = OP_GREF_APPLYC;
		     bv[ bv.size() - optab[prev_op].nbytes ] = op;
		     break;
		  }
		  case OP_FREF:
		  {
		     // convert fref to gref combo
		     if ( op == OP_PUSH_ARG )   op = OP_FREF_ARG;
		     else if ( op == OP_APPLY )	op = OP_FREF_APPLY;
		     else			op = OP_FREF_APPLYC;
		     bv[ bv.size() - optab[prev_op].nbytes ] = op;
		     break;
		  }
		  case OP_GET_ACCESS:
		  {
		     // convert get-access to get-access combo
		     if ( op == OP_PUSH_ARG )	op = OP_GET_ACCESS_ARG;
		     else if ( op == OP_APPLY )	op = OP_GET_ACCESS_APPLY;
		     else			op = OP_GET_ACCESS_APPLYC;
		     bv[ bv.size() - optab[prev_op].nbytes ] = op;
		     break;
		  }
		  default:
		     append_byte( bv, op );
		     break;
	       };
	       break;
#else
	       append_byte( bv, op );
	       break;
#endif
	    }

	    case OP_EXTEND_ENV:
	    {
	       // (extend-env <reg> <nvars> <vars>)
	       append_byte( bv, op );
	       x = cdr(x);
	       // x == (<reg> <nvars> ...)
	       append_byte( bv, find_reg(car(x)) );
	       x = cdr(x);
	       // x == (<nvars> <vars> ...)
	       append_byte( bv, fixnum(car(x)) );
	       append_byte( bv, add_sexpr( sv, car(cdr(x)) ) );
	       break;
	    }

	    case OP_ESET:
	    {
	       // (eset <index>)
	       append_byte( bv, op );
	       append_byte( bv, fixnum(car(cdr(x))) );
	       break;
	    }

	    default:
	       ERROR::severe( "assem: instruction not recognized/permitted", MEMORY::fixnum(op) );
	       break;
	 }

#ifdef DO_COMBOS
	 // fill pipe for peep
	 prev_op = op;
#endif
      }

      program = cdr(program);
   }

   resolve_jumps( bv, jumps, labels );

   SEXPR code = MEMORY::code( null, null );
   
   // protect it
   regstack.push( code );

   code_setbcodes( code, clone(bv) );
   code_setsexprs( code, clone(sv) );

   regstack.pop();

   sv_stack.pop_back();
   
   return code;
}

SEXPR ASSEM::encode()
{
   //
   // syntax: (assemble <program>)
   //
   ArgstackIterator iter;
   const SEXPR program = guard(iter.getlast(), listp);
   
   return encode( program );
}

//
// DECODE
//

static int get16( SEXPR bv, int target )
{
   const int b1 = bvecref(bv, target  );
   const int b2 = bvecref(bv, target+1);
   return b1 + (b2 << 8);
}

static void print_reg( SEXPR bv, int index )
{
   const unsigned reg = bvecref(bv, index);
   if ( reg < regtab.size() )
      printf( "%s", regtab[reg].name );
   else
      printf( "reg?" );
}

static void print_sexpr( SEXPR sv, SEXPR bv, int index )
{
   const int sexpr_index = bvecref(bv, index);
   const SEXPR sexpr = vectorref(sv, sexpr_index);
   PRINTER::print( sexpr );
}

static void print_byte( SEXPR bv, int index )
{
   printf( "%d", bvecref(bv, index) );
}

static void print_int16( SEXPR bv, int index )
{
   printf( "%d", get16(bv, index) );
}

static void print_code( int op, SEXPR bv, int index )
{
   const int max_len = 5;

   for ( int i = 0; i < max_len; ++i )
      if ( i < optab[op].nbytes )
	 printf( "%02x ", bvecref(bv, index+i) );
      else
	 printf( "%2s ", " ." );
}

static void indent( int level )
{
   for ( int i = 0; i < level; ++i )
      printf( "  " );
}


static void decode( SEXPR code, int level=0 )
{
   SEXPR bv = code_getbcodes(code);
   SEXPR sv = code_getsexprs(code);
   int index = 0;

   indent( level );
   printf( "%d:begin\n", level );

   indent( level );
   printf( "%d:sexprs ", level );
   PRINTER::print( sv );
   printf( "\n" );

   while ( index < getbveclength(bv) )
   {
      const unsigned op = bvecref(bv, index);
      if ( op >= optab.size() )
      {
         char buffer[80];
	 SPRINTF( buffer, "decode -- bad opcode (%d) at (%d)", op, index );
	 ERROR::severe( buffer, bv );
      }

      indent( level );
      printf( "%d:%04d: ", level, index );
      print_code( op, bv, index );
      printf( "%s", optab[op].name );

      switch ( op )
      {
	 case OP_SAVE_VAL:     // op=0
	 case OP_SAVE_AUX:     // op=1
	 case OP_SAVE_ENV:     // op=2
	 case OP_SAVE_UNEV:    // op=3
	 case OP_SAVE_EXP:     // op=4
	 case OP_SAVE_ARGC:    // op=5
	 case OP_SAVE_xxxx:    // op=6

	 case OP_RESTORE_VAL:  // op=7
	 case OP_RESTORE_AUX:  // op=8
	 case OP_RESTORE_ENV:  // op=9
	 case OP_RESTORE_UNEV: // op=10
	 case OP_RESTORE_EXP:  // op=11
	 case OP_RESTORE_ARGC: // op=12   
	 case OP_RESTORE_xxxx: // op=13

	 case OP_ZERO_ARGC:    // op=14
	 case OP_PUSH_ARG:     // op=15
	 case OP_POP_ARGS:     // op=16

	 case OP_APPLY:        // op=26
	 case OP_APPLY_CONT:   // op=27
	 case OP_TEST_TRUE:    // op=28
	 case OP_TEST_FALSE:   // op=29
	 case OP_BRANCH_CONT:  // op=31
	 case OP_GOTO_CONT:    // op=33
	 case OP_MAP_INIT:     // op=34
	 case OP_MAP_APPLY:    // op=35
	 case OP_MAP_RESULT:   // op=36
	 case OP_FOR_INIT:     // op=37
	 case OP_FOR_APPLY:    // op=38
	 case OP_FOR_RESULT:   // op=39
	 case OP_FORCE_VALUE:  // op=43
	 case OP_RTE:          //
	 case OP_RTC:          //
	    printf("\n");
	    break;
	    
	 case OP_ASSIGN_REG:   // op=17, [val,]reg
	 case OP_ASSIGN_REG_ARG:
	 case OP_ASSIGN_REG_APPLY:
	 case OP_ASSIGN_REG_APPLYC:
	    printf(" [val,]");
	    print_reg( bv, index+1 );
	    printf("\n");
	    break;

	 case OP_ASSIGN_OBJ:   // op=18, [val,]value
	 case OP_ASSIGN_OBJ_ARG:
	 case OP_ASSIGN_OBJ_APPLY:
	 case OP_ASSIGN_OBJ_APPLYC:
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf("\n");
	    break;
	    
	 case OP_GREF:         // op=19, [val,]sym
	 case OP_GREF_ARG:
	 case OP_GREF_APPLY:
	 case OP_GREF_APPLYC:
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf("\n");
	    break;

	 case OP_GSET:         // op=20, sym[,val]
	    printf(" ");
	    print_sexpr( sv, bv, index+1 );
	    printf("[,val]");
	    printf("\n");
	    break;
	    
	 case OP_FREF:         // op=21, [val],depth,index[,env]
	 case OP_FREF_ARG:
	 case OP_FREF_APPLY:
	 case OP_FREF_APPLYC:
	    printf(" [val,]");
	    print_byte( bv, index+1 );
	    printf(",");
	    print_byte( bv, index+2 );
	    printf("\n");
	    break;

	 case OP_FSET:         // op=22, depth,index,[val],[env]
	    printf(" ");
	    print_byte( bv, index+1 );
	    printf(",");
	    print_byte( bv, index+2 );
	    printf("\n");
	    break;
	    
	 case OP_GET_ACCESS:   // op=23, [val],sym,[val]
	 case OP_GET_ACCESS_ARG:
	 case OP_GET_ACCESS_APPLY:
	 case OP_GET_ACCESS_APPLYC:
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf("\n");
	    break;

	 case OP_SET_ACCESS:   // op=24, [val,]sym[,val][,exp/env]
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf(" ");
	    printf("[,exp]");
	    printf("\n");
	    break;
	 
	 case OP_LAMBDA:       // op=25, [val,]bcode,params,num,rest[,env]
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf(",");
	    print_sexpr( sv, bv, index+2 );
	    printf(",");
	    print_byte( bv, index+3 );
	    printf(",");
	    print_byte( bv, index+4 );
	    printf("\n");
	    {
	       const int code_index = bvecref( bv, index+1 );
	       decode( vectorref( sv, code_index ), level+1 );
	    }
	    break;
	    	    
	 case OP_DELAY:       // op=42, [val,]bcode
	    printf(" [val,]");
	    print_sexpr( sv, bv, index+1 );
	    printf("\n");
	    {
	       const int code_index = bvecref( bv, index+1 );
	       decode( vectorref( sv, code_index ), level+1 );
	    }
	    break;
	    	    
	 case OP_BRANCH:       // op=30, pc=bcode-index (3b)
	    printf(" ");
	    print_int16( bv, index+1 );
	    printf("\n");
	    break;
	    
	 case OP_GOTO:         // op=32, pc=bcode-index (3b)
	    printf(" ");
	    print_int16( bv, index+1 );
	    printf("\n");
	    break;
	    	    
	 case OP_EXTEND_ENV:   // op=40, reg,nvar,nvars
	    printf(" ");
	    print_reg( bv, index+1 );
	    printf(",");
	    print_byte( bv, index+2 );
	    printf(",");
	    print_sexpr( sv, bv, index+3 );
	    printf("\n");
	    break;
	    	    
	 case OP_ESET:        // op=41, index
	    printf(" ");
	    print_byte( bv, index+1 );
	    printf("[,val]");
	    printf("\n");
	    break;
	    	    
	 default:
	    break;
      }

      index += optab[op].nbytes;
   }

   indent( level );
   printf( "%d:end\n", level );
}

SEXPR ASSEM::decode()
{
   //
   // syntax: (disassemble <code>)
   //
   ArgstackIterator iter;
   const SEXPR code = guard(iter.getlast(), codep);
   decode( code, 0 );
   return null;
}

static void assem_marker()
{
   for ( auto svp : sv_stack )
   {
      for ( auto sexpr : *svp )
      {
         MEMORY::mark( sexpr );
      }
   }
}

void ASSEM::initialize()
{
   initialize_symbols();

   MEMORY::register_marker( assem_marker );
}

}
