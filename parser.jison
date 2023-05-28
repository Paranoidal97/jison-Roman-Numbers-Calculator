/* description: Parses and executes mathematical expressions. */

/* lexical grammar */
%lex
%%

\s+                   /* skip whitespace */
""                   return ''
"/"                   return '/'
"-"                   return '-'
"+"                   return '+'
"^"                   return '^'
"!"                   return '!'
"%"                   return '%'
"("                   return '('
")"                   return ')'
"PI"                  return 'PI'
"E"                   return 'E'
<<EOF>>               return 'EOF'
^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3}) return 'ROMAN'
.                     return 'INVALID'

/lex

/* operator associations and precedence */

%left '+' '-'
%left '*' '/'
%left '^'
%right '!'
%right '%'
%left UMINUS

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
    ;

e
    : e '+' e
        {$$ = $1+$3;}
    | e '-' e
        {$$ = $1-$3;}
    | e '*' e
        {$$ = $1*$3;}
    | e '/' e
        {$$ = $1/$3;}
    | e '^' e
        {$$ = Math.pow($1, $3);}
    | e '!'
        {{
          $$ = (function fact 👎 { return n==0 ? 1 : fact(n-1) * n })($1);
        }}
    | e '%'
        {$$ = $1/100;}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    | '(' e ')'
        {$$ = $2;}
    | ROMAN
        %{$$ = romanToArabic(yytext);%}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    ;

%%

function romanToArabic(roman){
    var totalValue = 0, 
        value = 0, // Initialise!
        prev = 0;
        
    for(var i=0;i<roman.length;i++){
        var current = char_to_int(roman.charAt(i));
        if (current > prev) {
            // Undo the addition that was done, turn it into subtraction
            totalValue -= 2 * value;
        }
        if (current !== prev) { // Different symbol?
            value = 0; // reset the sum for the new symbol
        }
        value += current; // keep adding same symbols
        totalValue += current;
        prev = current;
    }
    return totalValue;
}

function char_to_int(character) {
    switch(character){
        case 'I': return 1;
        case 'V': return 5;
        case 'X': return 10;
        case 'L': return 50;
        case 'C': return 100;
        case 'D': return 500;
        case 'M': return 1000;
        default: return -1;
    }
}