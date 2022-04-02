# Pascal-S语言编译程序的设计与实现

# 1 课程设计任务和目标 

## 1.1 任务

按照所给Pascal-S语言的语法，参考Pascal语言的语义，设计并实现Pascal-S语言的编译程序，给出各阶段的设计文档和实现成果。

要求给出各阶段的设计成果，如：

- 需求分析报告

- 总体设计报告（软件功能描述、功能模块划分、软件结构图、符号表结构设计、 模块间接口定义等）

- 详细设计报告（模块功能、输入/输出、处理逻辑等）

- 编码实现（源程序、可执行程序）

- 测试报告（测试计划、测试用例、测试结果及分析等）

## 1.2 目标

- 知识和技能
  - 原理：词法分析、语法分析、语义分析、（中间）代码生成 
  - 技术：基于自动机的分析技术、语法制导翻译技术 

- 综合能力，解决复杂工程问题的能力
  - 分析问题、问题分解 
  - 解决方案、方案实施 
  - 表达、沟通交流

# 2 需求分析 ：数据流图、功能及数据说明等

## 2.1 整体概况

编译器分为本地编译器、交叉编译器和”源码到源码编译器“。我们的目标是将Pascal-S语言编译生成C语言，因此属于”源码到源码编译器“。

一个完整的编译器包括分析阶段和综合阶段。分析阶段由词法分析、语法分析、语义分析组成；综合阶段由中间代码生成、代码优化、代码生成组成。因为目标代码C语言是高级语言，所以不需要生成中间代码，也就不需要代码优化，最终只要完成这四部分：词法分析、语法分析、语义分析和目标代码生成。

## 2.2 数据流图

![image-20220329180633856](https://gitee.com/chrislion/typora_image_repo/raw/master/img/image-20220329180633856.png)

## 2.3 功能需求

### 2.3.1 词法分析

词法分析程序的功能是输入某种源程序字符流，输出相应的记号序列（类别编码和属性信息）和错误信息。

词法分析程序应从左到右依次逐个字符扫描源程序字符流，按照源语言的词法规则识别出各类单词符号，从而产生用于语法分析的记号序列，并把识别出来的标识符存入符号表中。此外，还可以完成一些与用户接口有关的任务，如识别源程序中的注释和跳过空格，把来自编译程序的错误信息和源程序联系起来。同时应进行词法检查和错误处理与恢复。

#### 记号的识别

识别单词是按照记号的模式进行的，一种记号的模式匹配一类单词的集合。记号是指某一类单词符号的类别编码，如标识符的记号为id，常数的记号为num等。模式指某一类单词符号的构词规则，如标识符的模式是“由字母开头的字母数字串”。单词指某一类单词符号的一个特例，如position是标识符。

词法分析程序在识别出一个记号后，要把与之有关的信息作为它的属性保留下来。记号影响语法分析的决策，属性影响记号的翻译。在词法分析阶段，对记号只能确定一种属性，如标识符的属性是单词在符号表中的入口指针，常数的属性是它所表示的值，而对于关键字、运算符、分界符，其所对应的单词是唯一的，所以可以不设置属性，即属性域可以为空。

#### 记号的描述

设计词法分析程序，要对模式给出规范、系统的描述，需要用到正规表达式和正规文法。

Pascal语言的词法规定如下：

> - 源程序中的关键字（除开头的 program 和末尾的 end 之外）前、后必须有空格符或换行符，其它单词间的空格符是可选的。 
> - 源程序中的注释 
>   - 形式：{……} 
>   - 可以出现在任何单词之后
>   - 编译程序应该可以处理注释 
> - 标识符 
>   - 以字母开头的字母数字串，不区分大小写。 
>   - 定义为： 
>     - letter → [a-zA-Z] 
>     - digit → [0-9] 
>     - id → letter ( letter | digit ) * 
>   - 对其最大长度可以规定一个限制，比如 8个字符。
>
> - 常数 
>   - 整型常数、实型常数。 
>   - 定义为： 
>     - digits→ digits digit | digit 
>     - optional_fraction→ . digits | 
>     - num→digits optional_fraction 
> - 关键字作为保留字，如program, var, procedure, begin, if, else, … 
> - 关系运算符 relop 代表 =、<>、<、<=、>、>= 
> - addop 代表运算符 +、- 和 or 
> - mulop 代表运算符 * 、/、div、mod 和 and 
> - assignop 代表赋值号 :=

#### 错误处理

词法分析程序应检查源程序中存在的词法错误，并报告错误所在的位置。并对源程序中出现的错误进行适当的恢复，使词法分析可以继续进行。

词法分析阶段的错误主要就是读到非法字符（不属于该语言的字符集的字符），通常的做法是跳过非法字符，继续进行词法分析，同时需要输出详细的词法错误列表（错误发生的行数等），以便程序员修改词法错误。

### 2.3.2 语法分析

语法分析是编译程序的核心工作，由语法分析程序完成。语法分析程序依据源语言的语法规则，从词法分析获得的源程序记号序列中识别出各类语法成分，从而构造用于语义分析的语法分析树。同时还要进行语法检查，判断记号序列中是否存在语法错误，若存在需要报告错误的性质和位置并做出相应处理。

完成语法分析有两种方法：自顶向下的预测分析方法、自底向上的LR分析方法。Pascal语言的构造文法是一个LALR(1)文法，我们将借助YACC工具，使用LALR(1)自底向上分析方法进行语法分析。编写构造LALR(1)分析表的程序，并编码实现LR分析程序。

#### Pascal语言的语法规则

Pascal语言的文法产生的每一个句子都是一个Pascal-S程序，包括：

- 程序头：program......
- 全局常量的声明语句（可选）：const......
- 过程和/或函数的定义（可选）： procedure …… / function …… 
- 主程序体/复合语句： begin …… end 

过程和函数定义不允许嵌套。 

复合语句允许嵌套。 

过程和函数可以递归调用。 

参数传递方式：传值调用和引用调用（传地址）

注意 产生式 factor→ id 

- id既可以是函数名，也可以是常量名、简单变量名。 
- 对无参数函数的调用和引用简单变量的值，在语法上没有区别。 

例如，对于赋值语句 a:=b  

- 如果 b 是常量名，则把 b 的值赋予 a； 
- 如果 b 是简单变量，则把 b 的右值赋予 a； 
- 如果 b 是函数，则把函数 b 的返回值赋予 a。

#### 文法产生式

> programstruct → program_head ；program_body . 
>
> program_head → program id ( idlist ) | program id 
>
> program_body → const_declarations 
>
> ​								var_declarations 
>
> ​								subprogram_declarations 
>
> ​								compound_statement 
>
> idlist → id | idlist , id 
>
> const_declarations → ε | const const_declaration ; 
>
> const_declaration → id = const_value | const_declaration ; id = const_value 
>
> const_value → + num | - num | num | ′ letter ′
>
> var_declarations → ε | var var_declaration ; 
>
> var_declaration → idlist : type | var_declaration ; idlist : type 
>
> type → basic_type | array [ period ] of basic_type 
>
> basic_type → integer | real | boolean | char 
>
> period → digits .. digits | period ， digits .. Digits 
>
> subprogram_declarations → ε | subprogram_declarations subprogram ; 
>
> subprogram → subprogram_head ; subprogram_body 
>
> subprogram_head → procedure id formal_parameter | function id formal_parameter : basic_type 
>
> formal_parameter → ε | ( parameter_list )  
>
> parameter_list → parameter | parameter_list ; parameter
>
> parameter → var_parameter | value_parameter 
>
> var_parameter → var value_parameter 
>
> value_parameter → idlist : basic_type 
>
> subprogram_body → const_declarations var_declarations compound_statement 
>
> compound_statement → begin statement_list end 
>
> statement_list → statement | statement_list ; statement
>
> statement → ε | variable assignop expression | func_id assignop expression | procedure_call | compound_statement | if expression then statement else_part | for id assignop expression to expression do statement | read ( variable_list ) | write ( expression_list ) 
>
> variable_list → variable | variable_list , variable 
>
> variable → id id_varpart 
>
> id_varpart →ε | [ expression_list ]
>
> procedure_call → id | id ( expression_list ) 
>
> else_part → ε | else statement  
>
> expression_list → expression | expression_list , expression  
>
> expression → simple_expression | simple_expression relop simple_expression 
>
> simple_expression → term | simple_expression addop term  
>
> term → factor | term mulop factor 
>
> factor → num | variable | ( expression ) | id ( expression_list ) | not factor | uminus factor

#### 错误处理

编译时大多数错误的诊断和恢复工作集中在语法分析阶段。

语法分析程序应清楚而准确地报告发现的错误，如错误的位置和性质，并迅速地从错误中恢复过来，不应该明显地影响编译程序对正确程序的处理效率。

错误处理的策略包括：紧急恢复，短语级恢复，出错产生式，全局纠正。应结合实际对不同的错误进行对应的处理和恢复。

### 2.3.3 语义分析

语义分析程序的任务是收集并保存上下文有关的信息以及类型检查。它以语法树为基础，根据源语言的语义，通过将变量的定义与变量的引用联系起来，对源程序的含义进行检查，检查每一个语法成分是否具有正确的语义，最终输出带有语义信息的语法树，有助于生成正确的目标代码。

此外语义分析程序还应建立和管理符号表：在分析声明语句时，收集所声明标识符的有关信息，如类型、存储位置、作用域等，并记录在符号表中。只要编译时控制处于声明该标识符的程序块中，就可以从符号表中查到它的记录。

#### 符号表

首先设计符号表的结构（逻辑结构和物理结构），确定符号表的内容和管理程序。

符号表的内容应包括：

- 名字、类型
- 数组
- 函数

管理程序应包括：

- 查找
- 插入
- 定位
- 重定位

### 2.3.4 代码生成

代码生成输入注释分析树和符号表，输出目标代码。目标代码要求能在gcc编译器下正确编译，生成的可执行文件能够正确执行，在合法的输入下，得到正确的输出结果。

由于Pascal-S程序和C程序的结构不完全一致，故不能逐句翻译输出，应确定好源语言和目标语言的映射关系，进而设计实现代码生成。

# 3 总体设计

——分析方法的选择、软件功能结构及模块划分、模块间接口 的定义(包括全局数据结构的定义)。 

编译程序的总体流程：

- 词法分析程序生成记号序列
- 语法分析程序利用记号序列生成语法分析树
- 语义分析程序分析语法树，生成注释分析树，建立完善符号表
- 代码生成程序生成目标代码

## 3.1 数据结构设计

#### 记号

```C++
class node
{
	string token; // 记号的名称
	string value; // 属性值
}
```

#### 语法树

```
class node
{
	string token; // 记号的名称
	string value; // 属性值
	vector<class node*> children; // 子节点
}
```

#### 符号表

| 记录                        | 作用                                                         |      |
| --------------------------- | ------------------------------------------------------------ | ---- |
| 种类标志                    | 记录标识符的符号种类                                         |      |
| 标识符名字                  | 用于在进行添加、查找、修改等操作时识别匹配标识符             |      |
| 行号                        | 方便获取出错的具体位置                                       |      |
| 类型                        | 取值包括”integer”、”real”、”char”、”boolean”                 |      |
| 常量取值                    | 方便后续计算常量表达式的值                                   |      |
| 参数个数/数组维数           | 对于数组类型的变量，存储其维数；对于函数类型，存储其参数个数 |      |
| 数组各维上下界              | 便于判断其是否越界                                           |      |
| 指向函数/过程子符号表的指针 | 便于进行定位和重定位处理                                     |      |

种类标志包括：

- "normal variant"表示普通变量
- "constant"表示常量
- "array"表示数组
- "value parameter"表示传值参数
- "var parameter"表示传引用参数
- "procedure"表示过程
- "function"表示函数。

## 3.2 总体结构设计

### 3.2.1 功能模块的划分及功能

#### 词法分析模块

- 输入：Pascal-S源程序代码
- 输出：记号序列
- 功能：词法分析程序从左到右依次逐个字符扫描源程序字符流，按照源语言的词法规则识别出各类单词符号，从而产生用于语法分析的记号序列，并把识别出来的标识符存入符号表中。此外，识别源程序中的注释和跳过空格，把来自编译程序的错误信息和源程序联系起来。同时进行词法检查和错误处理与恢复。

#### 语法分析模块

- 输入：记号序列
- 输出：抽线语法树
- 功能：语法分析程序依据源语言的语法规则，从词法分析获得的源程序记号序列中识别出各类语法成分，从而构造用于语义分析的语法分析树。同时还要进行语法检查，判断记号序列中是否存在语法错误，若存在需要报告错误的性质和位置并做出相应处理。

#### 语义分析模块

- 输入：抽象语法树
- 输出：注释分析树、符号表
- 功能：
  - 语义分析程序以语法树为基础，根据源语言的语义，通过将变量的定义与变量的引用联系起来，对源程序的含义进行检查，检查每一个语法成分是否具有正确的语义，最终输出带有语义信息的语法树，有助于生成正确的目标代码
  - 建立及维护符号表
  - 类型检查
  - 错误检查处理

#### 代码生成模块

- 输入：注释分析树、符号表
- 输出：C语言代码
- 功能：遍历抽象语法树，并借助符号表的信息生成目标代码

### 3.2.2 模块之间的关系

![image-20220329180633856](https://gitee.com/chrislion/typora_image_repo/raw/master/img/image-20220329180633856.png)

### 3.2.3 模块之间的接口



## 3.3 用户接口设计







# 4 详细设计

说明，包括：

  接口描述

  功能描述

  所用数据结构说明

  算法描述





*1、接口描述：*

*语义分析：*

*输入：语法树，每个节点都是一个结构体，结构体中需要包含*

*记号：叶子节点中的标识符的id，非叶子结点为空*

*所在行：叶子节点所在的行数*

*属性：以该结点为根节点的子树所代表的语法成分*

*子结点域：存放指向子结点的指针*

*输出：符号表、语法树*

# 5 源程序清单

  注意编程风格，如：

  使用有意义的变量名、程序的缩排、程序的内部注释

# 6 程序测试

给出测试报告，包括：

1）测试环境

2）测试的功能

3）针对每个功能的测试情况，包括：测试用例、预期的结果、测试结果及其分析

在设计测试计划时，不但要考虑正确的测试用例，还要考虑含有错误的测试用例。

# 7 课程设计总结

\1) 体会/收获（每个成员完成的工作、收获等）

\2) 设计过程中遇到或存在的主要问题及解决方案

\3) 改进建议