#include "assem.hxx"

#include <cstdio>
#include <vector>

#include "code.hxx"

#include "core/error.hxx"
#include "core/argstack.hxx"
#include "core/printer.hxx"
#include "core/pio.hxx"
#include "core/memory.hxx"
#include "core/regstack.hxx"
#include "core/symtab.hxx"
#include "core/format.hxx"

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
//   (gdef <sym>)
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
//   (rte)
//   (rtc)
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
   { OP_GDEF,              2, "gdef"         , nullptr }, // op=21
   
   { OP_FREF,              3, "fref"         , nullptr }, // op=22
   { OP_FSET,              3, "fset"         , nullptr }, // op=23
   { OP_GET_ACCESS,        2, "get-access"   , nullptr }, // op=24
   { OP_SET_ACCESS,        2, "set-access"   , nullptr }, // op=25
   { OP_LAMBDA,            5, "make-closure" , nullptr }, // op=26
   { OP_APPLY,             1, "apply"        , nullptr }, // op=27
   { OP_APPLY_CONT,        1, "apply-cont"   , nullptr }, // op=28
   { OP_TEST_TRUE,         1, "test-true"    , nullptr }, // op=29
   { OP_TEST_FALSE,        1, "test-false"   , nullptr }, // op=30
   { OP_BRANCH,            3, "branch"       , nullptr }, // op=31
   { OP_BRANCH_CONT,       1, "branch-cont"  , nullptr }, // op=32
   { OP_GOTO,              3, "goto"         , nullptr }, // op=33
   { OP_GOTO_CONT,         1, "goto-cont"    , nullptr }, // op=34
   { OP_MAP_INIT,          1, "map-init"     , nullptr }, // op=35
   { OP_MAP_APPLY,         1, "map-apply"    , nullptr }, // op=36
   { OP_MAP_RESULT,        1, "map-result"   , nullptr }, // op=37
   { OP_FOR_INIT,          1, "for-init"     , nullptr }, // op=38
   { OP_FOR_APPLY,         1, "for-apply"    , nullptr }, // op=39
   { OP_FOR_RESULT,        1, "for-result"   , nullptr }, // op=40
   { OP_EXTEND_ENV,        4, "extend-env"   , nullptr }, // op=41
   { OP_ESET,              2, "eset"         , nullptr }, // op=42
   { OP_DELAY,             2, "delay"        , nullptr }, // op=43
   { OP_FORCE_VALUE,       1, "force-value"  , nullptr }, // op=44

   // exit(s)
   { OP_RTE,               1, "rte"          , nullptr }, // op=45
   { OP_RTC,               1, "rtc"          , nullptr }, // op=46
   
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
   auto v = MEMORY::byte_vector( bv.size() );

   for ( int i = 0; i < bv.size(); i += 1 )
      bvecset( v, i, bv[i] );

   return v;
}

static SEXPR clone( std::vector<SEXPR>& sv )
{
   auto v = MEMORY::vector( sv.size() );

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

   while ( !nullp(program) )
   {
      auto x = car(program);

      if ( symbolp(x) || fixnump(x) )
      {
	 add_assoc( labels, x, bv.size() );
      }
      else
      {
	 if ( verbose )
	 {
	    PRINTER::print(x);
	    PRINTER::newline();
	 }

	 // encode the instruction
	 const auto opsym = car(x);
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
	       const auto source = car(cdr(cdr(x)));

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
		  const auto obj = car(cdr(source));
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
	       const auto obj = car(cdr(cdr(x)));
	       append_byte( bv, add_sexpr( sv, obj ) );
	       break;
	    }

	    case OP_GDEF:
	    case OP_GSET:
	    {
	       // (gset <sym>) 
	       append_byte( bv, op );
	       const auto obj = car(cdr(x));
	       append_byte( bv, add_sexpr( sv, obj ) );
	       break;
	    }

	    case OP_FREF:
	    {
	       // (fref <reg> <depth> <index>) 
	       append_byte( bv, op );
	       const auto di = cdr(cdr(x));          // (<depth> <index>)
	       append_byte( bv, fixnum(car(di)) );
	       append_byte( bv, fixnum(car(cdr(di))) );
	       break;
	    }

	    case OP_FSET:
	    {
	       // (fset <depth> <index>)
	       append_byte( bv, op );
	       const auto di = cdr(x);               // (<depth> <index>)
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
	       const auto cs = car(cdr(cdr(x)));   // (const <sym>)
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
	       const auto cs = car(cdr(cdr(x)));   // (const <sym>)
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
	       append_byte( bv, x == symbol_true ? 1 : 0 );
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
	       const auto target = car(cdr(x));

	       if ( car(target) == symbol_label )
	       {
		  op = OP_BRANCH;
		  // (label <label>)
		  append_byte( bv, op );
		  const auto label = car(cdr(target));
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
	       const auto target = car(cdr(x));

	       if ( car(target) == symbol_label )
	       {
		  op = OP_GOTO;
		  // (label <label>)
		  append_byte( bv, op );
		  const auto label = car(cdr(target));
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
	    case OP_PUSH_ARG:
	    case OP_APPLY:
	    case OP_APPLY_CONT:
	    {
	       append_byte( bv, op );
	       break;
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
      }

      program = cdr(program);
   }

   resolve_jumps( bv, jumps, labels );

   auto code = MEMORY::code( null, null );
   
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
   const auto program = guard(iter.getlast(), listp);
   
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
      PIO::put( regtab[reg].name );
   else
      PIO::put( "reg?" );
}

static void print_sexpr( SEXPR sv, SEXPR bv, int index )
{
   const int sexpr_index = bvecref(bv, index);
   const auto sexpr = vectorref(sv, sexpr_index);
   PRINTER::print( sexpr );
}

static void print_byte( SEXPR bv, int index )
{
   PIO::put( format( "%d", (int)bvecref(bv, index))  );
}

static void print_int16( SEXPR bv, int index )
{
   PIO::put( format( "%d", get16(bv, index) ) );
}

static void print_code( int op, SEXPR bv, int index )
{
   const int max_len = 5;

   for ( int i = 0; i < max_len; ++i )
      if ( i < optab[op].nbytes )
      {
         PIO::put( format( "%02x ", (int)bvecref(bv, index+i) ) );
      }
      else
      {
         PIO::put( format( "%2s ", " ." ) );
      }
}

static void indent( int level )
{
   for ( int i = 0; i < level; ++i )
      PIO::put( "  " );
}


static void decode( SEXPR code, int level=0 )
{
   auto bv = code_getbcodes(code);
   auto sv = code_getsexprs(code);
   int index = 0;

   indent( level );
   PIO::put( format("%d:begin\n", level) );

   indent( level );
   PIO::put( format("%d:sexprs ", level) );
   PRINTER::print( sv );
   PIO::put( "\n" );

   while ( index < getbveclength(bv) )
   {
      const unsigned op = bvecref(bv, index);
      if ( op >= optab.size() )
      {
	 ERROR::severe( format("decode -- bad opcode (%d) at (%d)", (int)op, index).c_str(), bv );
      }

      indent( level );
      PIO::put( format( "%d:%04d: ", level, index ) );
      
      print_code( op, bv, index );
      PIO::put( optab[op].name );

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
	 case OP_APPLY:        // op=
	 case OP_APPLY_CONT:   // op=
	 case OP_TEST_TRUE:    // op=
	 case OP_TEST_FALSE:   // op=
	 case OP_BRANCH_CONT:  // op=
	 case OP_GOTO_CONT:    // op=
	 case OP_MAP_INIT:     // op=
	 case OP_MAP_APPLY:    // op=
	 case OP_MAP_RESULT:   // op=
	 case OP_FOR_INIT:     // op=
	 case OP_FOR_APPLY:    // op=
	 case OP_FOR_RESULT:   // op=
	 case OP_FORCE_VALUE:  // op=
	 case OP_RTE:          //
	 case OP_RTC:          //
            PIO::put( "\n" );
	    break;
	    
	 case OP_ASSIGN_REG:   // op=17, [val,]reg
            PIO::put( " " );
	    print_reg( bv, index+1 );
            PIO::put( "\n" );
	    break;

	 case OP_ASSIGN_OBJ:   // op, [val,]value
            PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
            PIO::put( "\n" );
	    break;
	    
	 case OP_GREF:         // op, [val,]sym
            PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
            PIO::put( "\n" );
	    break;

	 case OP_GSET:         // op, sym[,val]
	 case OP_GDEF:         // op, sym[,val]
            PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
            PIO::put( "\n" );
	    break;
	    
	 case OP_FREF:         // op=, [val],depth,index[,env]
	    PIO::put( " " );
	    print_byte( bv, index+1 );
	    PIO::put( "," );
	    print_byte( bv, index+2 );
	    PIO::put( "\n" );
	    break;

	 case OP_FSET:         // op, depth,index,[val],[env]
	    PIO::put( " " );
	    print_byte( bv, index+1 );
	    PIO::put( "," );
	    print_byte( bv, index+2 );
	    PIO::put( "\n" );
	    break;
	    
	 case OP_GET_ACCESS:   // op, [val],sym,[val]
	    PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
	    PIO::put( "\n" );
	    break;

	 case OP_SET_ACCESS:   // op, [val,]sym[,val][,exp/env]
	    PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
	    PIO::put( " " );
	    PIO::put( "\n" );
	    break;
	 
	 case OP_LAMBDA:       // op, [val,]bcode,params,num,rest[,env]
	    PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
	    PIO::put( "," );
	    print_sexpr( sv, bv, index+2 );
	    PIO::put( "," );
	    print_byte( bv, index+3 );
	    PIO::put( "," );
	    print_byte( bv, index+4 );
	    PIO::put( "\n" );
	    {
	       const int code_index = bvecref( bv, index+1 );
	       decode( vectorref( sv, code_index ), level+1 );
	    }
	    break;
	    	    
	 case OP_DELAY:       // op, [val,]bcode
	    PIO::put( " " );
	    print_sexpr( sv, bv, index+1 );
	    PIO::put( "\n" );
	    {
	       const int code_index = bvecref( bv, index+1 );
	       decode( vectorref( sv, code_index ), level+1 );
	    }
	    break;
	    	    
	 case OP_BRANCH:       // op, pc=bcode-index (3b)
	    PIO::put( " " );
	    print_int16( bv, index+1 );
	    PIO::put( "\n" );
	    break;
	    
	 case OP_GOTO:         // op, pc=bcode-index (3b)
	    PIO::put( " " );
	    print_int16( bv, index+1 );
	    PIO::put( "\n" );
	    break;
	    	    
	 case OP_EXTEND_ENV:   // op, reg,nvar,nvars
	    PIO::put( " " );
	    print_reg( bv, index+1 );
	    PIO::put( "," );
	    print_byte( bv, index+2 );
	    PIO::put( "," );
	    print_sexpr( sv, bv, index+3 );
	    PIO::put( "\n" );
	    break;
	    	    
	 case OP_ESET:        // op, index
	    PIO::put( " " );
	    print_byte( bv, index+1 );
	    PIO::put( "\n" );
	    break;
	    	    
	 default:
	    break;
      }

      index += optab[op].nbytes;
   }

   indent( level );
   PIO::put( format( "%d:end\n", level )  );
}

SEXPR ASSEM::decode()
{
   //
   // syntax: (disassemble <code>)
   //
   ArgstackIterator iter;
   const auto code = guard(iter.getlast(), codep);
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
