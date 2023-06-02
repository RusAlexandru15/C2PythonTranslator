%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yydebug=1;

int yylex();
void yyerror(const char *s);

char* maindef="if __name__ == 'main':";



char* createSpaces(int n);


int nrSpace=0;


%}
%union {char* svalue;}


%token <svalue> VAR
%token <svalue> NUM
%token <svalue> OP
%token <svalue> IFOP
%token <svalue> SHORTOP
%token <svalue> COMLINE
%token <svalue> PRINT

%token  IF
%token  ELIF
%token  ELSE
%token  ANDOP
%token  OROP

%token  FOR
%token  WHILE

%token OPENBRACE
%token CLOSEBRACE

%token  SHORTPLUS
%token  SHORTMINUS

%right IFOP
%nonassoc ANDOP OROP
%nonassoc EXPRX
%left OP


%type <svalue> expr
%type <svalue> statement
%type <svalue> atribstatement
%type <svalue> ifstatement
%type <svalue> ifbloc
%type <svalue> cond
%type <svalue> ifcomplet
%type <svalue> elsestatement
%type <svalue> elifstatement
%type <svalue> forstatement
%type <svalue> forcond
%type <svalue> printstatement
%type <svalue> listaPrint
%type <svalue> whilestatement
%type <svalue> eliflist
%%


program : program statement        { printf("%s",createSpaces(1)); printf("%s\n",$2); }
        |                          {printf("\n%s\n",maindef);}
        ;
        
statement : VAR '=' expr ';'       {$$=strdup($1);  strcat($$,"=");  strcat($$,$3);}
          | VAR SHORTOP expr ';'   {$$=strdup($1);  strcat($$,$2);  strcat($$,$3);}
          |VAR SHORTPLUS ';'       {$$=strdup($1);strcat($$,"+");strcat($$,"=");strcat($$,"1");}
          |VAR SHORTMINUS ';'      {$$=strdup($1);strcat($$,"-");strcat($$,"=");strcat($$,"1");}
          | ifcomplet              {$$=strdup($1);}
          | forstatement            {$$=strdup($1);}
          |COMLINE               {asprintf(&$$,"#%s",$1); }
          |printstatement ';'    {$$=strdup($1);}
          |whilestatement        {$$=strdup($1);}
          ;

ifcomplet :ifstatement  elsestatement       { asprintf(&$$,"%s\n%s",$1,$2); }
          |ifstatement eliflist  elsestatement     { asprintf(&$$,"%s\n%s\n%s",$1,$2,$3);}
          |ifstatement                           {/* cod*/}  
          ;
          
eliflist: elifstatement           { asprintf(&$$,"%s",$1); }
        | eliflist elifstatement  {asprintf(&$$,"%s\n%s",$1,$2); } 
        ;          
                  
/* if elif  else*/          
ifstatement:   IF '(' cond ')' openbr  ifbloc  closebr  {asprintf(&$$,"if %s:\n%s",$3,$6);  }
           ;

elifstatement: ELIF '(' cond ')' openbr  ifbloc  closebr  {asprintf(&$$,"elif %s:\n%s",$3,$6);   }
           ;
           
elsestatement:  ELSE  openbr  ifbloc  closebr {asprintf(&$$,"else:\n%s",$3);}        
             ;
   
/* while */
whilestatement:   WHILE '(' cond ')' openbr  ifbloc  closebr  {asprintf(&$$,"while %s:\n%s",$3,$6);  }   
           ;
           
/* for */       
forstatement: FOR '(' forcond ')'   openbr  ifbloc  closebr  {asprintf(&$$,"for i in range%s:\n%s",$3,$6);  }   
            ;
            
forcond: VAR '=' NUM ';' VAR IFOP NUM ';' VAR SHORTPLUS   { asprintf(&$$,"(%s)",$7);  }
       | VAR '=' NUM ';' VAR IFOP NUM ';' VAR SHORTMINUS   {asprintf(&$$,"(%s,%s,-1)",$3,$7); }
       ;                                                   
           

/* print */
printstatement : PRINT '(' '"' VAR '"' ',' listaPrint ')' {asprintf(&$$,"%s(\"%s\",%s)",$1,$4,$7);}
               ;
               
listaPrint:  VAR   {asprintf(&$$,"%s",$1); }
          | listaPrint ',' VAR  {asprintf(&$$,"%s,%s",$1,$3);}
          ;                     
           
             
  
/* la inchiderea/deschiderea acoladelor se modifica nivelul de identare*/             
openbr: OPENBRACE {nrSpace+=2;}
      ;
      
closebr: CLOSEBRACE {nrSpace-=2;}
       ;  
       
          


    
 ifbloc: atribstatement             {  $$=strdup(createSpaces(nrSpace)) ; strcat($$,$1); strcat($$,"\n"); } 
      | ifbloc atribstatement      {  strcat($$,createSpaces(nrSpace)) ; strcat($$,$2); strcat($$,"\n");  } 
      ;   
      
/* sintaxa permisa in blocul din if-for-while*/
atribstatement:  VAR '=' expr ';'       {asprintf(&$$,"%s = %s",$1,$3);  }
          | VAR SHORTOP expr ';'        {asprintf(&$$,"%s %s %s",$1,$2,$3); }
          |VAR SHORTPLUS ';'            {asprintf(&$$,"%s +=1",$1);}
          |VAR SHORTMINUS ';'           {asprintf(&$$,"%s -=1",$1);}   
          |printstatement ';'           {asprintf(&$$,"%s",$1);}
          |expr ';'                     {asprintf(&$$,"%s",$1);}
          |forstatement                {asprintf(&$$,"%s",$1);}
          |whilestatement                {asprintf(&$$,"%s",$1);}
          |ifcomplet                {asprintf(&$$,"%s",$1);}
          |COMLINE               {asprintf(&$$,"#%s",$1); }
          ;    
              
                  
/*conditia din if */         
cond : expr IFOP expr    {asprintf(&$$,"%s%s %s",$1,$2,$3);}
     | cond ANDOP cond   { asprintf(&$$,"%s and %s",$1,$3);}
     | cond OROP cond    { asprintf(&$$,"%s or %s",$1,$3);}
     ;        
          
          

/* expresii aritmetice */          
expr :  NUM %prec EXPRX      { asprintf(&$$,"%s",$1); }
     |  VAR %prec EXPRX      {asprintf(&$$,"%s",$1); }
     |  expr OP expr         { asprintf(&$$,"%s %s %s",$1,$2,$3);}
     | '('expr')'            { asprintf(&$$,"(%s)",$2);}
     ; 
%%


char* createSpaces(int n){
 char* spaces=(char*)malloc((n+1)*sizeof(char));
 
 for(int i=0;i<n;i++)
    spaces[i]=' ';
 spaces[n]='\0';
 return spaces;   
}
         

