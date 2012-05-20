#include <stdio.h>
#include <iostream>
#include <ctype.h>
#include "Example.hpp"

Example::Example()
{}

Example::~Example()
{}

char * Example::toUpper( char * str )
{
  char * p = str;
  while( * p ) {
    * p = toupper( * p );
    ++ p;
  }
  return str;
}

char * Example::toLower( char * str )
{
  char * p = str;
  while( * p ) {
    * p = tolower( * p );
    ++ p;
  }
  return str;
}

void Example::print( char * str1, char * str2, int num )
{
  int i;
  for( i = 0; i < num; i ++ ) {
    std::cout << str1 << " " << str2 << " " << std::endl;
  }
}


