# Reference:
# - https://github.com/itod/parsekit/blob/master/res/objc.grammar
# - https://github.com/iamdc/Objective-C-Grammar/blob/master/ObjC.Grm

@builtin "whitespace.ne" # `_` means arbitrary amount of whitespace

@{%
  const head = (([h, ...tail]) => h)
  const second = d => d[1]
  const tail = (([h, ...tail]) => tail)
%}

Program -> _ ClassInterface _ {% second %}

Identifier_Name -> [a-zA-Z_$] [a-zA-Z0-9_$]:* {% d => d[0] + d[1].join('') %}
Identifier -> Identifier_Name

#
#@symbol = '@interface';
#@symbol = '@implementation';
#@symbol = '@end';
#@symbol = '@class';
#@symbol = '@protocol';
#
#    external-declaration:
#    function-definition
#    declaration
#    class-interface
#    class-implementation
#    category-interface
#    category-implementation
#    protocol-declaration
#    class-declaration-list
#
#externalDecl = functionDef | decl | classInterface | classImpl | categoryInterface | categoryImpl | protocolDecl | classDeclList;
#
# class-interface:
# @interface class-name [ : superclass-name ]
# [ protocol-reference-list ]
# [ instance-variables ]
# [ interface-declaration-list ]
# @end
#
# TODO: add ivars
ClassInterface ->
  "@interface" _ ClassName (" : " SuperclassName):? _ ProtocolReferenceList:? _ InterfaceVariables:? _ InterfaceDeclarationList:? _ "@end;"
  {% d => {
    return {
      type: 'ClassInterface',
      value: d[2],
      parameters: {
        superclassName: d[3],
        protocolRefList: d[5],
        interfaceVariables: d[7],
        interfaceDeclList: d[9],
      }
    };
  } %}

# class-implementation:
# @implementation class-name [ : superclass-name ]
# [ instance-variables ]
# [ implementation-definition-list ]
# @end
#
#classImpl = '@implementation' className (':' superclassName)? ivars? implementationDefList? '@end';
#
# category-interface:
# @interface class-name ( category-name )
# [ protocol-reference-list ]
# [ interface-declaration-list ]
# @end
#
#categoryInterface = '@interface' className '(' categoryName ')' protocolRefList? InterfaceDeclarationList? '@end';
#
#category-implementation:
#@implementation class-name ( category-name )
#[ implementation-definition-list ]
#@end
#
#protocol-declaration:
#@protocol protocol-name
#[ protocol-reference-list ]
#[ interface-declaration-list ]
#@end


ClassDeclarationList ->
  "@class " ClassList ";" {% second %}

ClassList ->
    ClassName {% head %}
  | ClassList ", " ClassName {% d => d[0].concat(d[2]) %}

ProtocolReferenceList ->
  "<" ProtocolList ">" {% second %}

ProtocolList ->
  ProtocolName {% head %}
  | ProtocolList ", " ProtocolName {% d => d[0].concat(d[2]) %}

ClassName ->
  Identifier {% head %}

SuperclassName ->
  Identifier {% head %}

CategoryName ->
  Identifier {% head %}

ProtocolName ->
  Identifier {% head %}

#
#instance-variables:
#{ [ visibility-specification ] struct-declaration-list [ instance-variables ] }
#
#visibility-specification:
#@private
#@protected
#@public
#

InterfaceDeclarationList ->
  Declaration {% head %}
  | MethodDeclaration {% head %}
  | InterfaceDeclarationList __ Declaration {% d => d[0].concat(d[2]) %}
  | InterfaceDeclarationList __ MethodDeclaration {% d => d[0].concat(d[2]) %}

MethodDeclaration ->
  ClassMethodDeclaration
  | InstanceMethodDeclaration

ClassMethodDeclaration ->
  "+ " MethodType MethodSelector ";" {% d => ({
    type: 'ClassMethod',
    methodType: d[1],
    methodSelector: d[2],
  })
  %}

InstanceMethodDeclaration ->
  "- " MethodType MethodSelector ";"

#implementation-definition-list:
#function-definition
#declaration
#method-definition
#implementation-definition-list function-definition
#implementation-definition-list declaration
#implementation-definition-list method-definition
#
#method-definition:
#class-method-definition
#instance-method-definition
#
#class-method-definition:
#+ [ method-type ] method-selector [ declaration-list ] compound-statement
#
#instance-method-definition:
#- [ method-type ] method-selector [ declaration-list ] compound-statement
#

MethodSelector ->
  UnarySelector
  | KeywordSelector
  #keyword-selector [ , ... ]
  #keyword-selector [ , parameter-type-list ]

UnarySelector ->
  Selector {% head %}

KeywordSelector ->
  KeywordDeclarator
  | KeywordSelector KeywordDeclarator

KeywordDeclarator ->
  ":" MethodType Identifier
  | Selector ":" MethodType Identifier

Selector ->
  Identifier {% head %}

MethodType ->
  "(" TypeSpecifier ")" {% second %}

TypeName ->
  Identifier {% head %}
#
#
#Type Specifiers
#type-specifier:
TypeSpecifier ->
  "void"
  | "char"
  | "short"
  | "int"
  | "long"
  | "float"
  | "double"
  | "signed"
  | "unsigned"
  | "id"
  #id [ protocol-reference-list ]
  #class-name [ protocol-reference-list ]
  #struct-or-union-specifier
  #enum-specifier
  #typedef-name

#struct-or-union-specifier:
#struct-or-union [ identifier ] { struct-declaration-list }
#struct-or-union [ identifier ] { @defs ( class-name ) }
#struct-or-union identifier
#
#
#Type Qualifiers
#type-qualifier:
#const
#volatile
#protocol-qualifier
#
#protocol-qualifier:
#in
#out
#inout
#bycopy
#byref
#oneway
#
#
#Primary Expressions
#primary-expression:
#identifier
#constant
#string
#( expression )
#self
#message-expression
#selector-expression
#protocol-expression
#encode-expression
#
#message-expression:
#[ receiver message-selector ]
#
#receiver:
#expression
#class-name
#super
#
#message-selector:
#selector
#keyword-argument-list
#
#keyword-argument-list:
#keyword-argument
#keyword-argument-list keyword-argument
#
#keyword-argument:
#selector : expression
#: expression
#
#selector-expression:
#@selector ( selector-name )
#
#selector-name:
#selector
#keyword-name-list
#
#keyword-name-list:
#keyword-name
#keyword-name-list keyword-name
#
#keyword-name:
#selector :
#:
#
#protocol-expression:
#@protocol ( protocol-name )
#
#encode-expression:
#@encode ( type-name )
