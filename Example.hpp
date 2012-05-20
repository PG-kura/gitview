#ifndef __Example_hpp
#define __Example_hpp

class Example
{
public:
  Example();
  ~Example();

  char * toUpper( char * str );
  char * toLower( char * str );
  void print(char * str1, char * str2, int num = 1 );
};

#endif

