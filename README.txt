This README file explains the contents of the coursework submission for the compilers module.
Student Number: 201102762

Files included:
-> spl.bnf - BNF file
-> spl.l - Lexical Analyser
-> spl.c - Main method with yydebug code
-> spl.y - Parse Tree + code generation
-> CompileAll.bat - Batch file used to compile all programs after changes
-> DEBUG_Flex_Bison_Gcc.bat - Batch file used to compile programs quicker after changes - this one was a debug mode and certain methods in the code are only defined if the DEBUG is defined at compile time.
-> Flex_Bison_Gcc.bat - Batch file used to compile programs quicker after changes instead of manually typing them
-> README.txt - this file detailing files, assumptions, enhancements and testing

Test files included
-> a.SPL to e.SPL - files provided to parse and compile
-> Additional Tests folder - This folder contains the following:
----------------------------------------------------------------------------
---> README.txt - provided by Martin Walker explaining folder contents
---> Test001.spl to Test160.spl - Test SPL files provided by Martin Walker
---> Test001.spl.c to Test160.spl.c - C file that have been compiled from the SPL files provided in this folder. Some are missing as they didn't compile.
---> Test001.spl.c.exe to Test160.spl.c.exe - Compiled C files
---> Tests.txt - provided by Martin Walker explaining expected results from compilation of the files provided.
---> CompileAll.bat - Batch file that was used to compile from SPL to C and C to exe file automatically. The output was compared with Tests.txt manually.
----------------------------------------------------------------------------

Progress made with coursework
-> BNF definition - COMPLETE
-> Lexical analyser - COMPLETE
-> Symbol table usage - COMPLETE
-> Parse Tree - COMPLETE
-> Code Generation - COMPLETE
-> Optimisations - Not as many as wanted. Enhancements completed have been detailed below.

Assumptions/considerations made for SPL
-> The programs provided would be correct and the code generation would fully compile a working C script for each file (a.SPL through e.SPL)
-> For loops were created with the assistance from the FAQ, and a partial explanation is in the comments in the code generation part

Enhancements made
-> Identfiers are checked for C keyword conflicts
-> Warnings or comments are left in a comment section at the bottom of the C file for any identifiers or other code that is removed or modified
-> Debug mode outputs a symbol table printout/visualisation

Testing done
-> After changes were made to the program, the CompileAll.bat file was run to check that all the programs provided compilers
-> The 160 additional programs were compiled automatically using a batch script and compared manually to the document provided to verify that the program result matched what was expected
