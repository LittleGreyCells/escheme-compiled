#ifndef IMAGER_HXX
#define IMAGER_HXX

#include <string>

#include "core/sexpr.hxx"

namespace escheme
{

namespace IMAGER
{
   // load and evaluate the image elements
   void image_load( const std::string& fname_in );

   // load but do not evaluate the image elements
   SEXPR image_get_one( const std::string& fname_in );
   SEXPR image_get_all( const std::string& fname_in );
}

}

#endif
