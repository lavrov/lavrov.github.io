# Scala 3

#### A new language or cosmetic changes
<small>[Vitaly Lavrov](https://www.linkedin.com/in/vitaliy-lavrov-14b62042/) @ Amsterdam.scala</small>

---

## About me

- Using Scala since 2011
- Plain functional programmer ([?](https://www.youtube.com/watch?v=YXDm3WHZT5g))

---

# FP + OOP = 🤝

<blockquote>
“My goal is to show that a fruitful fusion between OO and Functional exists. 
For me, that's what Scala is about.”
</blockquote>
-- Martin Odersky <small><a href="https://github.com/lampepfl/dotty/pull/4153#issuecomment-377939928"><i class="fas fa-link"></i></a></small>

---

## 🔥 Dotty == Scala 3 🔥

- ETA 2020
- Scala 2.14 migration release

---

## Rationale

- Strong formal foundation (DOT calculus)
- Simplification (language and internals)
- Refinement
- Consistency
- Safety
- Performance

---

## DOT Calculus

- [DOT calculus](http://www.scala-lang.org/blog/2016/02/03/essence-of-scala.html)
  - Ensuring type soundness
  - Detect hidden connection between language features

--

## Dependent types

```scala
trait Generic[T] {

  type Repr

  def to(t : T) : Repr
}

def toGeneric[A](value: A)
                (implicit gen: Generic[A]): gen.Repr = 
  gen.to(value)
```

--

## Objects are galaxies in the Universe

<!-- .slide: data-background="/assets/images/galaxy_collision.gif" -->

Collisions may happen

[Example](https://scastie.scala-lang.org/lavrov/A6mAzwdISji2WHizFiOatw)

--

```scala
trait A { type T >: Any }
def id(a: A, x: Any): a.T = x
val p: A { type T <: Nothing } = null
def stringToInt(x: String): Int = id(p, x)
stringToInt("blah")
```
[Run](https://scastie.scala-lang.org/lavrov/75KRB8JjQhCYMad8gfEijg)

---

## Simplification

--

<!-- .slide: data-background="/assets/images/scala_contributors.png" -->

--

<blockquote>...it's impossible to make it fast if nobody can modify it...they will never make it fast, not without rewriting it</blockquote>
-- Paul Phillips

<small>We're Doing It All Wrong at Pacific Northwest Scala 2013 <small><a href="https://www.youtube.com/watch?v=TS1lpKBMkgg"><i class="fas fa-link"></i></a></small><small>

---

## Refinement

- Better dependent types support
- Enums
- Type lambdas
- Extension clause
- Cleaner syntax
  - Uncluttered if, for and while
  - Named type parameters
  - <del>Procedure Syntax</del>
- Type inference

--

### Better dependent types support

```scala
def serialize[A](a: A)(implicit gen: Generic[A], ser: JsonSerializer[gen.Out]): Json = {
  ser.serialize(gen(a))
}
```
instead of
```scala
object Generic {
  type Aux[A, R] = Generic[A] { type Repr = R }
}
def serialize[A, R](a: A)(implicit gen: Generic.Aux[A, R], ser: JsonSerializer[R]): Json = {
   ser.serialize(gen(a))

```

<small>[The Type Astronaut's Guide to Shapeless](https://underscore.io/books/shapeless-guide/)</small>

--

### Enums

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

### Type lambdas

```scala
type T[X] = (X, X)
type T = [X] => (X, X)
```

```scala
trait Functor[F[_]] {
  def map[B, C](fa: F[B])(f: B => C): F[C]
}
implicit def eitherFunctor[L] = {
  type RightEither[R] = Either[L, R]
  new Functor[RightEither] {
    def map[B, C](fa: F[B])(f: B => C): F[C] = fa.right.map(f)
  }
}
```
<!-- .element: class="fragment" -->
```scala
implicit def eitherFunctor[L] = 
  new Functor[[R] => Either[L, R]] {
    def map[B, C](fa: F[B])(f: B => C): F[C] = fa.right.map(f)
  }
```
<!-- .element: class="fragment" -->

--

### Extension clause

```scala
case class Circle(x: Double, y: Double, radius: Double)

extension CircleOps for Circle {
  def circumference: Double = this.radius * math.Pi * 2
}
```
instead of
```scala
implicit class CircleOps(val circle: Circle) extends AnyVal {
  def circumference: Double = circle.radius * math.Pi * 2
}
```

--

## Typeclass Traits

<!-- .slide: data-background="#b2250c" -->

```scala
trait SemiGroup extends TypeClass {
  def add(that: This): This
}

trait Monoid extends SemiGroup {
  common def unit: This
}
```

--

<!-- .slide: data-background="#b2250c" -->

```scala
enum Nat extends Monoid {
  case Zero
  case Succ(n: Nat)

  def add(that: Nat): Nat = this match {
    case Zero => that
    case Succ(n) => Succ(n.add(that))
  }
  common def unit = Zero
}
```
```scala
extension NatMonoid for Nat : Monoid {
  def add(that: Nat) = this match {
    case Zero => that
    case Succ(n) => Succ(n add that)
  }
  common def unit = Nat.Zero
}
```
```scala
val n1: Nat = ???
val n2: Nat = ???
n1.add(n2)
```

--

### Cleaner syntax

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
```scala
def map[A, B](fa: F[A])(f: A => B): F[B] = ???
map[B = Int](fa)(x => a.toInt + 1)
```

--

### Improved type inferrence

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

### Improved type inferrence

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

## Consistency

- Intersection types `A & B`
- Implicit function types
- Dependent function types
- Trait parameters
  - <del>Early initializers</del>
- Generic tuple aka HList
- <del>Existential types</del> (partially)

--

### Intersection types

```scala
trait A { type T = Int }
trait B { type T = String }

type C = A with B

val v: C#T = "baz"

// val v1: C#T = 1
```
<small>[Run](https://scastie.scala-lang.org/lavrov/WAixCrXpSiCvo8wnI8z5nQ)</small>

Compound types are not commutative:
```scala
A with B
// is not the same as
B with A
```
--

### Intersection types

```scala
trait A { type T = Int }
trait B { type T = String }

type C = A & B

val v: C#T = "baz"
```
<small>[Run](https://scastie.scala-lang.org/lavrov/rjwrj9aOTVqWIptRJOWxew)</small>

--

### Implicit functions

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

### Implicit functions

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

### Effects

<!-- .slide: data-background="#b2250c" -->

[Example](https://scastie.scala-lang.org/lavrov/DO0uPQAcSqK55RRhKQqbBw)

--

### Dependent function types

```scala
trait Entry { type Key; val key: Key }

def extractKey(e: Entry): e.Key = e.key          // a dependent method
val extractor: (e: Entry) => e.Key = extractKey  // a dependent function value
//            ║   ⇓ ⇓ ⇓ ⇓ ⇓ ⇓ ⇓   ║ 
//            ║     Dependent     ║  
//            ║   Function Type   ║  
//            ╚═══════════════════╝
```

--

### Trait parameters

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

```scala
object Bar extends { val name = "Bar"} with Foo
```
<!-- .element: class="fragment" -->

<del class="fragment">Early Initializers</del>

--

### Trait parameters

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

## Generic Tuple

- head, tail, nth element access
- recursive at compile time so allows [typeclass induction](https://www.youtube.com/watch?v=CstiIq4imWM)
- plain case class or Array at runtime
- no 22 fields limit (represented as Array)
- [PR on github](https://github.com/lampepfl/dotty/pull/2199)

---

## Safety

- Union types `A | B`
- Multiversal equality
- Restricted implicit conversions
- Null safety (planned)
- Effects (planned)
- <del>General type projection</del>

--

### Union types A | B

- Direct supertype of both `A` and `B` -- no need to widen to `Any`
- Precise types
- Commutative

```scala
enum Day {
  case Monday, Tuesday, Wednesday, Thursday, Firday, Saturday, Sunday
  
  type Weekend = Saturday.type | Sunday.type
}
```

--

### Multiversal equality

```scala
object Main {
  
  sealed trait Animal
  final case class Lion() extends Animal
  final case class Cow() extends Animal

  val cow = new Cow()
  val lion = new Lion()
  
  def main(args: Array[String]): Unit = {
    println(cow == lion)
  }
}
```
<small>[Run](https://scastie.scala-lang.org/lavrov/1qHPtZLMQ2m87iuylz2M6w)</small>

```scala
implicit def eqT: Eq[T, T] = Eq
```

```scala
import scala.language.strictEquality
```

---

## Performance

- Opaque type aliases (pending)
- Erased parameters
- Specialization (pending)

---

## TASTY

- Typed syntax trees representing code
- Compact, efficiently stored in bytecode
- Dotty can recompile from TASTY 
- One jar for JVM, JS and Native
- Allows library specific optimizations

<aside class="notes">
TASTY is a new serialization format for typed syntax trees of Scala programs. When compiled by Dotty, a program classfile will include its TASTY representation in addition to its bytecode.
Dotty uses ASTs from the TASTY in classfiles as input instead of source files.
This is the first step toward linking with advanced optimisations, recompiling code to a different backends…
</aside>

---

## DOTTYDOC

- Jekyll-like [static site](http://dotty.epfl.ch/docs/) generation
- Markdown
- Compiled examples
- Referencing, citing and rendering API in documentation

---

## Language Server

- Compiler knows everything about your code
- IDE/editor integration
- [LSP](https://github.com/Microsoft/language-server-protocol) by Microsoft
- Visual Studio Code

---

## Try it

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
