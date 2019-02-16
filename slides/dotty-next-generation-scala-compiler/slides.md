# Dotty

#### The next generation Scala compiler
<small>[Vitaly Lavrov](https://www.linkedin.com/in/vitaliy-lavrov-14b62042/)</small>

---

# What is Dotty?

- new compiler for Scala-like language
- developed at LAMP EPFL by [Martin Odersky](https://github.com/lampepfl/dotty/graphs/contributors) and his team
- under active development (unstable)
- [open source](https://github.com/lampepfl/dotty)

---

# Why?

- a proven foundation - [DOT Calculus](http://lampwww.epfl.ch/%7Eamin/dot/fool.pdf)
- new features
- simplification
- developer usability

---

## DOT

- [(D)ependent (O)bject (T)ypes](https://infoscience.epfl.ch//record/215280)
- [DOT calculus](http://www.scala-lang.org/blog/2016/02/03/essence-of-scala.html)
  - ensuring type soundness
  - feedback loop for language design
  - detect hidden connection between language features
- has to be studied and extended to cover all language features
  - type parameters
  - variance
  - traits
  - classes
  - inheritance

  <aside class="notes">
  The lack of a formal specification might be the source problems. Nobody tries to 'just build' a building -- architects and engineers draw up plans and make models first. We wouldn't be surprised by an unplanned / undesigned building's collapse.
  If you leave out all the incidential features (many of them in fact just a syntactic surag) and look at concentrated essence of the language what do you get? Dotty team believes that DOT caclucus is the answer. It has been proven to be sound and has been machine-checked for correctness by EPFL team.
  A calculus is a kind of mini-language that is small enough to be studied formally.
  </aside>


---

## New Features 

- dependent types
- trait parameters
- implicit function types
- algebraic data types
- cleaner sytax
- improved type inferrence
- union and intersection types
- dependent function types
- type lambdas
- ...

--

Dependent types

```scala
trait GenRep[A] { 
  type Out 
  def apply(a: A): Out 
}

trait JsonSerializer[A] {
  def serialize(a: A): Json
}
```
```scala

type Rep = ...
implicit def caseClassGenRep[A]: GenRep[Rep] = ... 
implicit def repJsonSerializer[R <: Rep]: JsonSerializer[R] = ...
```
<!--.element: class="fragment"-->
```scala
def serialize[A](a: A)(implicit gen: GenRep[A], ser: JsonSerializer[gen.Out]): Json = {
  ser.serialize(gen(a))
}
```
<!--.element: class="fragment"-->

--

Trait parameters

```scala
trait Foo {
    def name: String
    println(s"Initialized with: $name")
}
object Bar extends Foo {
    val name = "Bar"
}
```
<pre class="fragment"><code class="shell">
scala> Bar 
Initialized with: null
</code></pre>

<pre class="fragment"><code class="scala">
trait Foo(name: String) {
    println(s"Initialized with: $name")
}
object Bar extends Foo("Bar")
</code></pre>

<pre class="fragment"><code class="shell">
scala> Bar 
Initialized with: Bar
</code></pre>

--

Algebraic data types

<pre><code class="scala" data-noescape data-trim>
enum Color(val rgb: Int) {
  <span class="fragment">case Red   extends Color(0xFF0000)
  case Green extends Color(0x00FF00)
  case Blue  extends Color(0x0000FF)</span>
}
</code></pre>

<pre class="fragment"><code class="scala" data-noescape>
enum Option[+T] {
  <span class="fragment">case Some(x: T)
  case None</span>
  <span class="fragment">
  def isDefined: Boolean = this match {
    case None => false
    case some => true
  }</span>
}
</code></pre>

--

Implicit functions

<pre><code class="scala" data-noescape>
def fun(context: Context): String = ...
<span class="fragment">val fun: Context => String = ...</span>
</code></pre>

<pre class="fragment"><code class="scala" data-noescape>
def fun(implicit context: Context): Unit = ...
<span class="fragment">val fun: (<mark class="fragment">implicit</mark> context: Context) => Unit = ...</span>
</code></pre>
<pre class="fragment"><code class="scala" data-noescape>
def withContext[A](fn: Context => A) = try fn(createContext) catch ...
<span class="fragment">
withContext { implicit context => 
  implicitly[Context]
}
</span>
<span class="fragment">type Contextful[A] = implicit Context => A</span>
<span class="fragment">def withContext[A](fn: Contextful[A]) = try fn(createContext) catch ...</span>
<span class="fragment">
withContext { <mark class="fragment">implicit context =></mark>
  implicitly[Context]
}
</span>
</code></pre>

--

Implicit functions

```scala
def insert(n: Int)(implicit ctx: Context): Boolean = ...
```
```scala
def insert(n: Int): Contextful[Boolean] = {
  val ctx = implicitly[Context]
  ...
}
```
<!--.element: class="fragment"-->
```scala
insert(5)
1 |insert(5)
  |         ^
  |no implicit argument of type Context was found for parameter of Contextful[Boolean]
  |which is an alias of: implicit Context => Boolean
```
<!--.element: class="fragment"-->
```scala
withContext {
  insert(5)
}
```
<!--.element: class="fragment"-->

--

Cleaner syntax
```scala
if true then 1 else 0
```
```scala
for 
  l1 <- List(1, 2 ,3)
  l2 <- List(4, 5, 6)
yield
  (l1, l2)
```
```scala
def plus(a: Int, b: Int) = a + b
val plusFn = plus
```

--

Improved type inferrence

```scala
val opt = Option(1)
```
```
// Scala 2
scala> opt.fold(List.empty)(List(_))
<console>:13: error: type mismatch;
 found   : x$1.type (with underlying type Int)
 required: Nothing
       o.fold(List.empty)(List(_))
```
<!--.element: class="fragment"-->
```
// Dotty
scala> o.fold(List.empty)(List(_)) 
val res16: List[Int] = List(1)
```
<!--.element: class="fragment"-->

--

Improved type inferrence

```scala
def func[A, B](a: A, op: A => B): B = op(a)
```
```
// Scala 2
scala> func(6, _ + 1)
<console>:13: error: missing parameter type for expanded function ((x$1: <error>) => x$1.$plus(1))
       func(6, _ + 1)
```
<!--.element: class="fragment"-->
```
// Dotty
scala> func(6, _ + 1) 
val res1: Int = 7
```
<!--.element: class="fragment"-->

---

## What's planned

--

## Tuple as Hlist

- head, tail, nth element access
- [shapeless](https://github.com/milessabin/shapeless) with low overhead
- recursive at compile time so allows [typeclass induction](https://www.youtube.com/watch?v=CstiIq4imWM)
- plain case class at runtime
- no 22 fields limit (represented as Array)
- [PR on github](https://github.com/lampepfl/dotty/pull/2199)

--

## Revised metaprogramming

- quotation and splicing
- works for types
- 4th attempt (hope the last)

--

## Revised metaprogramming

```scala
inline def power(n: Int, x: Double): Double = ~{
  '(n) match {
    case Constant(n1) => powerCode(n1, '(x))
    case _ => '{ dynamicPower(n, x) }
  }
}
```
<pre class="fragment"><code class="scala">
private def powerCode(n: Int, x: Expr[Double]): Expr[Double] = 
  if (n == 0) '(1.0)
  else if (n == 1) x
  else if (n % 2 == 0) '{ { val y = ~x * ~x; ~powerCode(n / 2, '(y)) } }
  else '{ ~x * ~powerCode(n - 1, x) }
  </code></pre>

---

## Developer Usability

- faster compilation
- [TASTY](https://docs.google.com/document/d/1h3KUMxsSSjyze05VecJGQ5H2yh7fNADtIf3chD3_wr0)
- linker
  - auto specialization
  - library defined optimizations
- improved repl
- DOTTYDOC
- awesome error messages
- Language Server

--

### TASTY

- typed syntax trees representing code
- compact, efficiently stored in bytecode
- Dotty can recompile from TASTY 
- one jar for JVM, JS and Native
- allows library specific optimizations

<aside class="notes">
TASTY is a new serialization format for typed syntax trees of Scala programs. When compiled by Dotty, a program classfile will include its TASTY representation in addition to its bytecode.
Dotty uses ASTs from the TASTY in classfiles as input instead of source files.
This is the first step toward linking with advanced optimisations, recompiling code to a different backends…
</aside>

--

## Maintanability vs Performance

<pre class="fragment"><code class="java">
// Java
public double average(int[] data) {
    int sum = 0;
    for(int i = 0; i < data.length; i++) {
        sum += data[i];
    }
    return sum * 1.0d / data.length;
}
</code></pre>
<pre class="fragment"><code class="scala">
// Scala
def average(xs: Array[Int]) =
  xs.reduce(\_ + \_) * 1.0 / xs.size
</pre></code>

| Java          | Scala         |
| ------------- |:-------------:|
| 45 ms         | 872 ms        |
<!--.element: class="fragment"-->

--

Boxing is expensive

```scala
def reduce(op: Function2[Obj, Obj, Obj]): Obj = {
  var first = true
  var acc: Obj = null
  this.foreach { e =>
    if (first) {
      acc = e
      first = false
    } else acc = op.apply(acc, e)
  }
  acc
}
```
```scala
def foreach(f: Funtion1[Obj, Obj]) {
  var i = 0
  val len = length
  while (i < len) {
    f.apply(this(i))
    i += 1
  }
}
```

--

Boxing is expensive

```scala
// After erasure
def plus(a: Object, b: Object): Object
```
<!--.element: class="fragment"-->
```scala
// When applied to primitive types
plus(1, 1)
```
<!--.element: class="fragment"-->
```scala
// Expanded in runtime
unbox(plus(box(1), box(1), intNum))
```
<!--.element: class="fragment"-->

- single boxing(allocation) <!--.element: class="fragment"-->
- 5 dynamic dispatches <!--.element: class="fragment"-->
- 15 static dispatches <!--.element: class="fragment"-->
- 20 additions <!--.element: class="fragment"-->



--

Auto specialization

- analyses call graph (your code and libraries)
- generates specialized bytecode
- removes boxing
- automatic

| Java          | Dotty         |
| ------------- |:-------------:|
| 45 ms         | 68 ms         |
<!--.element: class="fragment"-->

--

## Library defined optimizations

```scala
x.length == 0
```
becomes
<!--.element: class="fragment"-->
```scala
x.isEmpty
```
<!--.element: class="fragment"-->
```scala
import dotty.linker._

@rewrites
object CollectionOptimization {
  def isEmpty(x: Seq[Int]) =
    Rewrite(from = x.length == 0,
            to   = x.isEmpty)
```
<!--.element: class="fragment"-->

--

Conditional rewrites

```scala
List(1, 2, 3).filter(_ > 1).filter(_ > 2)
```
becomes
<!--.element: class="fragment"-->
```scala
List(1, 2, 3).filter(x => x > 1 && x > 2)
```
<!--.element: class="fragment"-->
```scala
def twoFilters(x: List[Int], a: Int => Boolean, b: Int => Boolean)
  (implicit apure: IsPure[a.type]) =
    Rewrite(from = x.filter(a).filter(b),
            to   = x.filter(x => a(x) && b(x)))
```
<!--.element: class="fragment"-->
<mark>Must be pure!</mark>
<!--.element: class="fragment"-->

--

### DOTTYDOC

- Jekyll-like [static site](http://dotty.epfl.ch/docs/) generation
- markdown
- compiled examples
- referencing, citing and rendering API in documentation

--

### [awesome error messages](http://www.scala-lang.org/blog/2016/10/14/dotty-errors.html)

- verbose explanation via `-explain`
- type diff

--

### Language Server

- compiler knows everything about your code
- IDE/editor integration
- [LSP](https://github.com/Microsoft/language-server-protocol) by Microsoft
- Visual Studio Code

---

# Try it

```shell 
$ brew install lampepfl/brew/dotty
```
```shell
$ sbt new lampepfl/dotty.g8
```
```shell
$ git clone https://github.com/lampepfl/dotty-example-project
```
[Scastie](https://scastie.scala-lang.org/)

<small>Technology preview release every [six weeks](http://dotty.epfl.ch/docs/usage/version-numbers.html)

---

# Questions

---

# Links

- http://dotty.epfl.ch/
- https://www.cakesolutions.net/teamblogs/dotty
- https://d-d.me
- https://felixmulder.com/
- http://www.scala-lang.org/blog/2016/02/03/essence-of-scala.html
