#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*   One argument: filename.
 *
 *   Program checks file for missing brackets and interlocked brackets.
 *   Does not account for strings, e.g. "docstring 1)" is not ignored (todo).
 *   Maximum nesting depth is in constant MAXNEST.
 *
 *   Because file is processed from beginning to ending, opening
 *   and closing brackets are handled asymmetrically. The stack
 *   of opening brackets can shrink and grow; the stack of closing
 *   brackets is really a pile, as a non-matching closing bracket
 *   will never be matched (going from top to bottom in the file).
 */

#define MAXNEST 1024

void tell_overflow (char c);
int f(char c);
char g(int i);
         
__inline__ int f(char c) {      
   switch(c) {
      case '(': return 0;
      case ')': return 1;
      case '{': return 2;
      case '}': return 3;
      case '[': return 4;
      case ']': return 5;
   }
   return 6;
}

__inline__ char g(int i){
   switch(i) {
      case 0: return '(';
      case 1: return ')';
      case 2: return '{';
      case 3: return '}';
      case 4: return '[';
      case 5: return ']';
   }
   return '\0';
}

int
main(int argc, char *argv[])
{
   FILE *testfile;
   int c, i, j, k, lc, bc;
   int linenumbers[6][MAXNEST];  /* open bracket stack + closed bracket dump */
   int bytenumbers[6][MAXNEST];  /* open bracket stack + closed bracket dump */
   int nr_open[6];               /* size of stacks */

   int B_allmatch = 1;           /* all brackets match */
   int B_interlock = 0;          /* presence of interlock, e.g. ([)] */

   for (i=0;i<6;i++) {
      linenumbers[i][0] = -1;    /* perhaps not necessary */
      bytenumbers[i][0] = -1;
      nr_open[i]        =  0;
   }

   if (argc == 1) {
      testfile = stdin;
   }

   else if ((strcmp(argv[1], "-h"))==0) {
      printf("Usage: pch FILENAME or |pch\n");
      exit(0);
  }

   else if ((testfile = fopen(argv[1],"r")) == NULL) {
      printf("File %s could not be opened\n", argv[1]);
      exit(2);
   }

   lc = 1;                                      /* line count */
   bc = 0;                                      /* byte count */

   while ((c = fgetc(testfile)) != EOF) {

      int   brack =  f(c);

      if (c == '\n') {
         lc++;
         bc = 0;
         continue;
      }

      bc++;

      if (brack == 6) {                        /* Not A Bracket */
         continue;
      }
                                               /* OPENING BRACKET */
      if (brack % 2 == 0) {

         if (nr_open[brack] == (MAXNEST)) {
            tell_overflow(c);
            break;
         }
         else {
            linenumbers[brack][nr_open[brack] ] = lc;
            bytenumbers[brack][nr_open[brack] ] = bc;
            ++nr_open[brack];
         }
      }
                                       /* CLOSING BRACKET */
      else if (brack % 2 == 1) {
                                       /* there are open brackets of this
                                        * type
                                        */
         if (nr_open[brack-1] > 0) {
                                       /* check for interlock, i.e. ([)] */
            for (k=0;k<3;k++) {

               int      thatopen    =  2*k;
               int      thisopen    =  brack-1;

               if (  (nr_open[thatopen] == 0)
                  || (thatopen == thisopen)
                  )
                     continue;

               else {

                  int thisln   =  linenumbers[thisopen][nr_open[thisopen]-1];
                  int thatln   =  linenumbers[2*k][nr_open[thatopen]-1];
                  int thisbt   =  bytenumbers[thisopen][nr_open[thisopen]-1];
                  int thatbt   =  bytenumbers[2*k][nr_open[thatopen]-1];

                  if (  (thatln > thisln)
                     || ((thatln == thisln) && (thatbt > thisbt))
                     )
                  {
                     B_interlock = 1;

                     if (lc == thatln) {
                        fprintf  (  stdout
                                 ,  "%d-%d,%d interlocked pair %c%c\n"
                                 ,  lc
                                 ,  thatbt
                                 ,  bc
                                 ,  g(2*k)
                                 ,  c
                                 )  ;
                     }
                     else {
                        fprintf  (  stdout
                                 ,  "%d-%d, %d-%d interlocked pair %c%c\n"
                                 ,  thatln
                                 ,  thatbt
                                 ,  lc
                                 ,  bc
                                 ,  g(2*k)
                                 ,  c
                                 )  ;
                     }
                  }
               }
            }

            --nr_open[brack-1];
         }
                                    /* closing bracket does not have opening */

         else if (nr_open[brack-1] == 0) {

            if (nr_open[brack] == (MAXNEST)) {
               tell_overflow(c);
               break;
            }

            else {
               linenumbers[brack][nr_open[brack]] = lc;
               bytenumbers[brack][nr_open[brack]] = bc;
               ++nr_open[brack];
            }
         }
         else {}
      }
   }

   fclose(testfile);

   for (i=0;i<6;i++) {

      if (nr_open[i] > 0) {

         B_allmatch = 0;
         for (j = 0; j < nr_open[i]; j++) {
            printf("%d-%d ",linenumbers[i][j], bytenumbers[i][j]);
         }
         printf("unmatched %c\n",g(i));
      }
   }

   if (B_allmatch && !B_interlock) {
      printf("File is clear\n");
   }

   return 0;
}

void tell_overflow (char c) {

   printf("Overflow on bracket %c\n", c);
   printf("Nesting depth maximum equals %d\n", MAXNEST);

   return;
}

