#ifndef ASSEM_HXX
#define ASSEM_HXX

#include "core/sexpr.hxx"

namespace escheme
{

namespace ASSEM
{
   void initialize();
   
   SEXPR encode();
   SEXPR decode();
}

}

#endif
