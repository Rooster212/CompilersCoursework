########################################
#           Test information           #
########################################

Enclosed in this directory are 160 SPL test files, each of which generally tests one small element of your compiler.
Associated with many tests is an output .txt file, which shows the expected outcome of running the code produced by
the test (or indeed whether the test should even compile). In some cases there are also input files which show the
input needed to generate the expected outcome.

There are four types of tests:

#codegen tests
- These are tests that should definitely compile and execute; if compilation fails, or the output doesn't match, 
  the test fails. 

#option tests
- These are tests that may or may not compile, depending on your assumptions made about SPL. If it does compile, 
  output is compared as normal, though conceivably outputs could differ based on the differen assumptions.
  Examples include things like typing: some compilers may choose to be strongly typed, whereas others might 
  permit implicit type coercion. Similarly, you could choose to quit on any semantic error, or try to continue.

#warning tests
- These are tests that should not compile really, but could potentially compile and produce a warning if your
  compiler is quite lenient. These are equivalent to (but a bit more serious than) compile warnings from GCC
  or Visual Studio. Examples include certain semantic errors and type coercion errors, e.g. assigning a non-
  letter to a character type. If code is generated even with a warning, its output is checked as normal.

#error tests
- Thats that should definitely not compile, e.g. due to syntax errors etc. If you produce a complete .c file 
  for these then your compiler is probably in error.

All of the tests, together with their category above, are listed in tests.txt, which includes a brief description
of what is being tested. 

Note that the test are provided solely for your own experimentation and to help inspire similar tests of your own. 
We will not be providing any support for these tests -- it is up to you to run them, check the outcome, and make 
any necessary changes to your compiler.

During the demos we will also be using additional tests besides these. However, if your compiler manages to pass
the vast majority (90%+), then that is a good sign of a fairly robust and successful parser, one which stands a 
good chance of passing our other tests as well.
