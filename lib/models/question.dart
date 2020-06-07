class Question{
  String subject;

  Question(this.subject);

  List questions(){
    if(subject=="C++"){
      return [
        {"question":"Which of the following is the correct syntax of including a user defined header files in C++?",
          "option":["#include <userdefined.h>","#include <userdefined>",'#include “userdefined”',"#include [userdefined]"],
          "answer":2},
        {"question":"Which of the following is a correct identifier in C++?",
          "option":["7var_name","7VARNAME",'VAR_1234',"\$var_name"],
          "answer":2},
        {"question":"Which of the following is called address operator?",
          "option":["*","&",'_',"%"],
          "answer":1},
        {"question":"Which of the following is used for comments in C++?",
          "option":["// comment","/* comment */",'both // comment or /* comment */'," // comment */"],
          "answer":2},
        {"question":"What are the actual parameters in C++?",
          "option":["Parameters with which functions are called","Parameters which are used in the definition of a function",'Variables other than passed parameters in a function',"Variables that are never used in the function"],
          "answer":0},
        {"question":"What are the formal parameters in C++?",
          "option":["Parameters with which functions are called","Parameters which are used in the definition of the function","Variables other than passed parameters in a function","Variables that are never used in the function"],
          "answer":1},
        {"question":"Which function is used to read a single character from the console in C++?",
          "option":["cin.get(ch)","getline(ch)",'read(ch)',"scanf(ch)"],
          "answer":0},
        {"question":"Which function is used to write a single character to console in C++?",
          "option":["cout.put(ch)","cout.putline(ch)","write(ch)","printf(ch)"],
          "answer":0},
        {"question":"What are the escape sequences?",
          "option":["Set of characters that convey special meaning in a program","Set of characters that whose use are avoided in C++ programs","Set of characters that are used in the name of the main function of the program","Set of characters that are avoided in cout statements"],
          "answer":0},
        {"question":"Who created C++?",
          "option":["Bjarne Stroustrup","Dennis Ritchie","Ken Thompson","Brian Kernighan"],
          "answer":0}
      ];
    }
    else if(subject=="Python"){
      return [
        {"question":"Is Python case sensitive when dealing with identifiers?",
          "option":["yes","no","machine dependent","none of the mentioned"],
          "answer":0},
        {"question":"What is the maximum possible length of an identifier?",
          "option":["31 characters","63 characters","79 characters","none of the mentioned"],
          "answer":3},
        {"question":"Which of the following is invalid?",
          "option":["_a = 1","__a = 1","__str__ = 1","none of the mentioned"],
          "answer":3},
        {"question":"Which of the following is an invalid variable?",
          "option":["my_string_1","1st_string","foo","_"],
          "answer":1},
        {"question":"Why are local variable names beginning with an underscore discouraged?",
          "option":["they are used to indicate a private variables of a class","they confuse the interpreter","they are used to indicate global variables","they slow down execution"],
          "answer":0},
        {"question":"Which of the following is not a keyword?",
          "option":["eval","assert","nonlocal","pass"],
          "answer":0},
        {"question":"Which of the following is true for variable names in Python?",
          "option":["unlimited length","all private members must have leading and trailing underscores","underscore and ampersand are the only two special characters allowed","none of the mentioned"],
          "answer":0},
        {"question":"Which of the following is an invalid statement?",
          "option":["abc = 1,000,000","a b c = 1000 2000 3000","a,b,c = 1000, 2000, 3000","a_b_c = 1,000,000"],
          "answer":1},
        {"question":"Which of the following cannot be a variable?",
          "option":["__init__","in","it","on"],
          "answer":1},
        {"question":"What arithmetic operators cannot be used with strings?",
          "option":["+","*","–","All of the mentioned"],
          "answer":2}
      ];
    }
  }


}
List subjects=[
  "C++",
  "Python"
];