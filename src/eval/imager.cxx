#include "imager.hxx"

#include "core/sexpr.hxx"
#include "core/reader.hxx"
#include "core/printer.hxx"
#include "core/pio.hxx"
#include "core/symtab.hxx"
#include "core/error.hxx"
#include "core/regstack.hxx"
#include "core/memory.hxx"
#include "eval.hxx"

static auto verbose = false;

//
// DUMP
//

static void dump_file( SEXPR iport, SEXPR oport, int nosily=0 )
{
}

void IMAGER::image_dump( const char* fname_in, const char* fname_out )
{
   // TBD
}

//
// LOAD
//

static void eval( SEXPR exp )
{
   EVAL::bceval( exp );
}

static SEXPR vector_to_bvec( SEXPR v )
{
   SEXPR bv = MEMORY::byte_vector( getvectorlength(v) );
   
   for ( int i = 0; i < getbveclength(bv); ++i )
      bvecset( bv, i, static_cast<BYTE>( getfixnum(vectorref(v, i)) ) );
   
   return bv;
}

static SEXPR load_code( SEXPR x );

static SEXPR load_sexprs( SEXPR x )
{
   // x = (<size> <tag> <item> ...);
   const SEXPR size = car(x);

   if ( !fixnump(size) )
      ERROR::severe( "not a legal size for sexprs vector", size );
   
   SEXPR sexprs = MEMORY::vector( static_cast<int>( getfixnum( size ) ) );

   regstack.push( sexprs );

   for ( int i = 0; i < getvectorlength(sexprs); ++i )
   {
      x = cdr(x);
      
      // x = (<tag> <item> <tag> <item> ...);
      SEXPR tag = guard( car(x), fixnump );
      
      x = cdr(x);
      // x = (<item> <tag> <item> ...);
      
      switch ( static_cast<int>( getfixnum(tag) ) )
      {
         case 0:
         {
            vectorset( sexprs, i, car(x) );
            break;
         }
         case 1:
         {
            SEXPR item = car(x);
            if ( car(item) == SYMTAB::enter("<code>")  )
               vectorset( sexprs, i, load_code( cdr(item) ) );
            else
               ERROR::severe( "expected <code>; got", item );
            break;
         }
         default:
         {
            ERROR::severe( "unrecognized tag", tag );
            break;
         }
      }
   }

   return regstack.pop();
}

static SEXPR load_code( SEXPR x )
{
   SEXPR v = car(x);

   if ( !vectorp(v) )
      ERROR::severe( "not a vector", v );

   x = car(cdr(x));

   if ( !(consp(x) && car(x) == SYMTAB::enter("<sexpr>")) )
      ERROR::severe( "not sexprs vector" );

   SEXPR sexprs = load_sexprs( cdr(x) );
   regstack.push( sexprs );
   
   SEXPR bvec = vector_to_bvec(v);
   regstack.push( bvec );
   
   SEXPR code = MEMORY::code( null, null );
   code_setbcodes(code, bvec);
   code_setsexprs(code, sexprs);
   
   regstack.pop();
   regstack.pop();
   
   return code;
}

static SEXPR try_load_code( SEXPR port )
{
   SEXPR x = READER::read(port);
   
   if ( consp(x) && car(x) == SYMTAB::enter("<code>") )
   {
      regstack.push( x );
      auto code = load_code( cdr(x) );
      regstack.pop();
      
      return code;
   }
   else
      return PIO::eof_object;
}

static void load_file( SEXPR port )
{
   SEXPR code = try_load_code(port);
   
   while ( !READER::eof_objectp(code) )
   {
      if ( verbose )
      {
         printf( "code: " );
         PRINTER::print( code );
         PRINTER::newline();
         printf( "  bcodes: ");
         PRINTER::print( code_getbcodes(code) );
         PRINTER::newline();
         printf( "  sexprs: ");
         PRINTER::print( code_getsexprs(code) );
         PRINTER::newline();         
      }
      // evaluate the constructed code object
      eval( code );
      
      code = try_load_code(port);
   }
}

void IMAGER::image_load( const char* fname )
{
   SEXPR port = PIO::open( MEMORY::string(fname), pm_input, "r" );
   
   regstack.push(port);
   load_file(port);
   regstack.pop();
   
   PIO::close(port);
}
