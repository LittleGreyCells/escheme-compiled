#ifndef CODE_HXX
#define CODE_HXX

namespace escheme
{

//
// Operation Structure
//
//   OP, dest(reg), source1, source2, ...
//   OP, dest(sym), val
//   OP, dest(frame), val
//

enum OpCodes
{
   OP_SAVE_VAL,     // op=0 (1b) 
   OP_SAVE_AUX,     // op=1
   OP_SAVE_ENV,     // op=2
   OP_SAVE_UNEV,    // op=3
   OP_SAVE_EXP,     // op=4
   OP_SAVE_ARGC,    // op=5
   OP_SAVE_xxxx,    // op=6

   OP_RESTORE_VAL,  // op=7 (1b)
   OP_RESTORE_AUX,  // op=8
   OP_RESTORE_ENV,  // op=9
   OP_RESTORE_UNEV, // op=10
   OP_RESTORE_EXP,  // op=11
   OP_RESTORE_ARGC, // op=12
   OP_RESTORE_xxxx, // op=13

   OP_ZERO_ARGC,    // op=14        (1b)
   OP_PUSH_ARG,     // op=15, [val] (1b)
   OP_POP_ARGS,     // op=16        (1b)

   OP_ASSIGN_REG,   // op=17, [val], reg2        (2b)
   OP_ASSIGN_OBJ,   // op=18, [val], value(SVI)  (2b)

   OP_GREF,         // op=19, [val], sym(SVI)    (2b)
   OP_GSET,         // op=20, sym(SVI), [val]    (2b)
   OP_GDEF,         // op=21, sym(SVI), [val]    (2b)

   OP_FREF,         // op=22, [val], depth, index, [env] (3b)
   OP_FSET,         // op=23, depth, index, [val], [env] (3b)

   OP_GET_ACCESS,   // op=24, [val], sym(SVI), [val]            (2b)
   OP_SET_ACCESS,   // op=25, [val], sym(SVI), [val], [exp/env] (2b)

   OP_LAMBDA,       // op=26, [val], bcode(CVI), params(CVI), num, rest, [env] (5b)

   OP_APPLY,        // op=27 (1b)
   OP_APPLY_CONT,   // op=28 (1b)

   OP_TEST_TRUE,    // op=29, [val] (1b)
   OP_TEST_FALSE,   // op=30, [val] (1b)

   OP_BRANCH,       // op=31, pc=bcode-index (3b)
   OP_BRANCH_CONT,  // op=32, next=cont      (1b)

   OP_GOTO,         // op=33, pc=bcode-index (3b)
   OP_GOTO_CONT,    // op=34                 (1b)

   OP_MAP_INIT,     // op=35 (1b)
   OP_MAP_APPLY,    // op=36 (1b)
   OP_MAP_RESULT,   // op=37 (1b)

   OP_FOR_INIT,     // op=38 (1b)
   OP_FOR_APPLY,    // op=39 (1b)
   OP_FOR_RESULT,   // op=49 (1b)

   OP_EXTEND_ENV,   // op=41, reg, nvars, vars(SVI), [env] (4b)
   OP_ESET,         // op=42, index, [val]                 (2b)

   OP_DELAY,        // op=43, code(SVI) (2b)
   OP_FORCE_VALUE,  // op=44

   OP_MREF,         // op=45, [val], depth, sym(SVI), [env] (3b)
   OP_MSET,         // op=46, depth, sym(SVI), [val], [env] (3b)
   OP_MDEF,         // op=47, sym(SVI), [val]    (2b)
   OP_MODULE,       // op=48 (1b)

   OP_RTE,          // op=49, return to eceval, cont <- top(evs)
   OP_RTC,          // op=50, return to c/c++ caller

};

enum REGISTERS
{
   REG_VAL = 0,
   REG_AUX,
   REG_ENV,
   REG_UNEV,
   REG_EXP,
   REG_ARGC,
   REG_xxxx,
};

//
// SVI = sexpr vector index
//
//    This is for symbols (lookup/ref/set) and other structured values.
//   

}

#endif
