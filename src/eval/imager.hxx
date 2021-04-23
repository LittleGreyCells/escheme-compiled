#ifndef IMAGER_HXX
#define IMAGER_HXX

#include <string>

#include "core/sexpr.hxx"

namespace escheme
{

namespace IMAGER
{
   // read and evaluate the image elements
   void load( const std::string& fname_in );

   // read but do not evaluate the image elements
   SEXPR read_one( const std::string& fname_in );
   SEXPR read_all( const std::string& fname_in );
}

}

#endif
