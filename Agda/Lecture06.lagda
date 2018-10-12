\begin{code}

{-# OPTIONS --without-K --allow-unsolved-metas #-}

module Lecture06 where

import Lecture05
open Lecture05 public

-- Section 6.1 Contractible types

is-contr : {i : Level} → UU i → UU i
is-contr A = Sigma A (λ a → (x : A) → Id a x)

center : {i : Level} {A : UU i} → is-contr A → A
center (dpair c C) = c

-- We make sure that the contraction is coherent in a straightforward way
contraction : {i : Level} {A : UU i} (H : is-contr A) →
  (const A A (center H) ~ id)
contraction (dpair c C) x = concat c (inv (C c)) (C x)

coh-contraction : {i : Level} {A : UU i} (H : is-contr A) →
  Id (contraction H (center H)) refl
coh-contraction (dpair c C) = left-inv (C c)

-- We show that contractible types satisfy an induction principle akin to the induction principle of the unit type: singleton induction. This can be helpful to give short proofs of many facts.

ev-pt : {i j : Level} (A : UU i) (a : A) (B : A → UU j) → ((x : A) → B x) → B a
ev-pt A a B f = f a

sing-ind-is-contr : {i j : Level} (A : UU i) (H : is-contr A) (B : A → UU j) →
  B (center H) → (x : A) → B x
sing-ind-is-contr A H B b x = tr B (contraction H x) b

sing-comp-is-contr : {i j : Level} (A : UU i) (H : is-contr A) (B : A → UU j) →
  (((ev-pt A (center H) B) ∘ (sing-ind-is-contr A H B)) ~ id)
sing-comp-is-contr A H B b =
  ap (λ (ω : Id (center H) (center H)) → tr B ω b) (coh-contraction H)

sec-ev-pt-is-contr : {i j : Level} (A : UU i) (H : is-contr A) (B : A → UU j) →
  sec (ev-pt A (center H) B)
sec-ev-pt-is-contr A H B = dpair (sing-ind-is-contr A H B) (sing-comp-is-contr A H B)

is-sing-is-contr : {i j : Level} (A : UU i) (H : is-contr A) (B : A → UU j) →
  sec (ev-pt A (center H) B)
is-sing-is-contr A H B =
  dpair (sing-ind-is-contr A H B) (sing-comp-is-contr A H B)

is-sing : {i : Level} (A : UU i) → A → UU (lsuc i)
is-sing {i} A a = (B : A → UU i) → sec (ev-pt A a B)

is-contr-sing-ind : {i : Level} (A : UU i) (a : A) → ((P : A → UU i) → P a → (x : A) → P x) → is-contr A
is-contr-sing-ind A a S = dpair a (S (λ x → Id a x) refl)

is-contr-is-sing : {i : Level} (A : UU i) (a : A) →
  is-sing A a → is-contr A
is-contr-is-sing A a S = is-contr-sing-ind A a (λ P → pr1 (S P))

is-sing-unit : is-sing unit star
is-sing-unit B = dpair ind-unit (λ b → refl)

is-contr-unit : is-contr unit
is-contr-unit = is-contr-is-sing unit star (is-sing-unit)

is-sing-total-path : {i : Level} (A : UU i) (a : A) →
  is-sing (Σ A (λ x → Id a x)) (dpair a refl)
is-sing-total-path A a B = dpair (ind-Σ ∘ (ind-Id a _)) (λ b → refl)

is-contr-total-path : {i : Level} (A : UU i) (a : A) →
  is-contr (Σ A (λ x → Id a x))
is-contr-total-path A a = is-contr-is-sing _ _ (is-sing-total-path A a)

-- Section 6.2 Contractible maps

-- We first introduce the notion of a fiber of a map.
fib : {i j : Level} {A : UU i} {B : UU j} (f : A → B) (b : B) → UU (i ⊔ j)
fib f b = Σ _ (λ x → Id (f x) b)

-- A map is said to be contractible if its fibers are contractible in the usual sense.
is-contr-map : {i j : Level} {A : UU i} {B : UU j} (f : A → B) → UU (i ⊔ j)
is-contr-map f = (y : _) → is-contr (fib f y)

-- Our goal is to show that contractible maps are equivalences.
-- First we construct the inverse of a contractible map.
inv-is-contr-map : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  is-contr-map f → B → A
inv-is-contr-map H y = pr1 (center (H y))

-- Then we show that the inverse is a section.
issec-is-contr-map : {i j : Level} {A : UU i} {B : UU j} {f : A → B}
  (H : is-contr-map f) → (f ∘ (inv-is-contr-map H)) ~ id
issec-is-contr-map H y = pr2 (center (H y))

-- Then we show that the inverse is also a retraction.
isretr-is-contr-map : {i j : Level} {A : UU i} {B : UU j} {f : A → B}
  (H : is-contr-map f) → ((inv-is-contr-map H) ∘ f) ~ id
isretr-is-contr-map {_} {_} {A} {B} {f} H x =
  ap {_} {_} {fib f (f x)} {A} pr1
    { dpair (inv-is-contr-map H (f x)) (issec-is-contr-map H (f x))}
    { dpair x refl}
    ( concat
      ( center (H (f x)))
      ( inv
        ( contraction
          ( H (f x))
          ( dpair
            ( inv-is-contr-map H (f x)) (issec-is-contr-map H (f x)))))
            ( contraction (H (f x)) (dpair x refl)))

-- Finally we put it all together to show that contractible maps are equivalences.
is-equiv-is-contr-map : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  is-contr-map f → is-equiv f
is-equiv-is-contr-map H =
  pair
    (dpair (inv-is-contr-map H) (issec-is-contr-map H))
    (dpair (inv-is-contr-map H) (isretr-is-contr-map H))

-- Section 6.3 Equivalences are contractible maps

-- The goal in this section is to show that all equivalences are contractible maps. This theorem is much harder than anything we've seen so far, but many future results will depend on it.

-- Before we start we will develop some of the ingredients of the construction.

-- We will need the naturality of homotopies.
htpy-nat : {i j : Level} {A : UU i} {B : UU j} {f g : A → B} (H : f ~ g)
  {x y : A} (p : Id x y) →
  Id (concat _ (H x) (ap g p)) (concat _ (ap f p) (H y))
htpy-nat H refl = right-unit (H _)

-- We will also need to undo concatenation on the left and right. One might notice that, in the terminology of Lecture 7, we almost show here that concat p and concat' q are embeddings.
left-unwhisk : {i : Level} {A : UU i} {x y z : A} (p : Id x y) {q r : Id y z} →
  Id (concat _ p q) (concat _ p r) → Id q r
left-unwhisk refl s = concat _ (inv (left-unit _)) (concat _ s (left-unit _))

right-unwhisk : {i : Level} {A : UU i} {x y z : A} {p q : Id x y}
  (r : Id y z) → Id (concat _ p r) (concat _ q r) → Id p q
right-unwhisk refl s = concat _ (inv (right-unit _)) (concat _ s (right-unit _))

-- We will also need to compute with homotopies to the identity function. 
htpy-red : {i : Level} {A : UU i} {f : A → A} (H : f ~ id) →
  (x : A) → Id (H (f x)) (ap f (H x))
htpy-red {_} {A} {f} H x = right-unwhisk (H x)
  (concat (concat (f x) (H (f x)) (ap id (H x)))
    (ap (concat (f x) (H (f x))) (inv (ap-id (H x)))) (htpy-nat H (H x)))

square : {i : Level} {A : UU i} {x y1 y2 z : A}
  (p1 : Id x y1) (q1 : Id y1 z) (p2 : Id x y2) (q2 : Id y2 z) → UU i
square p q p' q' = Id (concat _ p q) (concat _ p' q')

sq-left-whisk : {i : Level} {A : UU i} {x y1 y2 z : A} {p1 p1' : Id x y1}
  (s : Id p1 p1') {q1 : Id y1 z} {p2 : Id x y2} {q2 : Id y2 z} →
  square p1 q1 p2 q2 → square p1' q1 p2 q2
sq-left-whisk refl sq = sq

sq-top-whisk : {i : Level} {A : UU i} {x y1 y2 z : A}
  {p1 : Id x y1} {q1 : Id y1 z}
  {p2 p2' : Id x y2} (s : Id p2 p2') {q2 : Id y2 z} →
  square p1 q1 p2 q2 → square p1 q1 p2' q2
sq-top-whisk refl sq = sq

-- Now the proof that equivalences are contractible maps really begins. Note that we have already shown that any equivalence has an inverse. Our strategy is therefore to first show that maps with inverses are contractible, and then deduce the claim about equivalences.

center-has-inverse : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  has-inverse f → (y : B) → fib f y
center-has-inverse {i} {j} {A} {B} {f}
  (dpair g (dpair issec isretr)) y =
  dpair
    ( g y)
    ( concat _
      ( inv (ap (f ∘ g) (issec y)))
        ( concat _ (ap f (isretr (g y))) (issec y)))

contraction-has-inverse : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  (I : has-inverse f) → (y : B) → (t : fib f y) →
  Id (center-has-inverse I y) t
contraction-has-inverse {i} {j} {A} {B} {f}
  ( dpair g (dpair issec isretr)) y (dpair x refl) =
  eq-pair (dpair
    ( isretr x)
    ( concat _
      ( tr-id-left-subst (isretr x) (f x)
        ( pr2 (center-has-inverse
          ( dpair g (dpair issec isretr))
          ( f x))))
      ( inv (inv-con
        ( ap f (isretr x))
        ( refl)
        ( concat
          ( f (g (f (g (f x)))))
          ( inv (ap (λ z → f (g z)) (issec (f x))))
          ( concat (f (g (f x))) (ap f (isretr (g (f x)))) (issec (f x))))
        ( concat _
          ( right-unit (ap f (isretr x)))
          ( inv-con
            ( ap (f ∘ g) (issec y))
            ( ap f (isretr x))
            ( concat (f (g (f x))) (ap f (isretr (g (f x)))) (issec (f x)))
            ( sq-left-whisk
              {_} {_} {f(g(f(g(f x))))} {f(g(f x))} {f(g(f x))} {f x}
              { issec (f(g(f x)))} {ap (f ∘ g) (issec (f x))}
              ( htpy-red issec (f x))
              {ap f (isretr x)} {ap f (isretr (g (f x)))} { issec (f x)}
              ( sq-top-whisk
                {_} {_} {f(g(f(g(f x))))} {f(g(f x))} {f(g(f x))} {f x}
                { issec (f(g(f x)))} {_} {_} {_}
                ( concat _
                  ( ap-comp f (g ∘ f) (isretr x))
                  ( inv (ap (ap f) (htpy-red isretr x))))
                ( htpy-nat (htpy-right-whisk issec f) (isretr x))))))))))

is-contr-map-has-inverse : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  has-inverse f → is-contr-map f
is-contr-map-has-inverse {i} {j} {A} {B} {f} I y =
    dpair (center-has-inverse I y) (contraction-has-inverse I y)

is-contr-map-is-equiv : {i j : Level} {A : UU i} {B : UU j} {f : A → B} →
  is-equiv f → is-contr-map f
is-contr-map-is-equiv = is-contr-map-has-inverse ∘ has-inverse-is-equiv

is-contr-total-path' : {i : Level} (A : UU i) (a : A) →
  is-contr (Σ A (λ x → Id x a))
is-contr-total-path' A a = is-contr-map-is-equiv (is-equiv-id _) a

-- Exercises

-- Exercise 6.1

-- In this exercise we are asked to show that the identity types of a contractible type are again contractible. In the terminology of Lecture 8: we are showing that contractible types are propositions.

is-prop-is-contr : {i : Level} {A : UU i} → is-contr A →
  (x y : A) → is-contr (Id x y)
is-prop-is-contr {i} {A} C =
  sing-ind-is-contr A C
    ( λ x → ((y : A) → is-contr (Id x y)))
    ( λ y → dpair
      ( contraction C y)
      ( ind-Id
        ( center C)
        ( λ z (p : Id (center C) z) → Id (contraction C z) p)
        ( coh-contraction C)
        ( y)))

-- Exercise 6.2

-- In this exercise we are showing that contractible types are closed under retracts.
is-contr-retract-of : {i j : Level} {A : UU i} (B : UU j) →
  A retract-of B → is-contr B → is-contr A
is-contr-retract-of B (dpair i (dpair r isretr)) C =
  dpair
    (r (center C))
    (λ x → concat (r (i x)) (ap r (contraction C (i x))) (isretr x))

-- Exercise 6.3

-- In this exercise we are showing that a type is contractible if and only if the constant map to the unit type is an equivalence. This can be used to derive a '3-for-2 property' for contractible types, which may come in handy sometimes.

is-equiv-const-is-contr : {i : Level} {A : UU i} →
  is-contr A → is-equiv (const A unit star)
is-equiv-const-is-contr {i} {A} H =
  pair
    ( dpair (ind-unit (center H)) (ind-unit refl))
    ( dpair (const unit A (center H)) (contraction H))

is-contr-is-equiv-const : {i : Level} {A : UU i} →
  is-equiv (const A unit star) → is-contr A
is-contr-is-equiv-const (dpair (dpair g issec) (dpair h isretr)) =
  dpair (h star) isretr

is-contr-is-equiv : {i j : Level} {A : UU i} (B : UU j) (f : A → B) →
  is-equiv f → is-contr B → is-contr A
is-contr-is-equiv B f Ef C =
  is-contr-is-equiv-const
    (is-equiv-comp _ _ f (λ x → refl) Ef (is-equiv-const-is-contr C))

is-contr-is-equiv' : {i j : Level} (A : UU i) {B : UU j} (f : A → B) →
  is-equiv f → is-contr A → is-contr B
is-contr-is-equiv' A f Ef C =
  is-contr-is-equiv A (inv-is-equiv Ef) (is-equiv-inv-is-equiv Ef) C

is-equiv-is-contr : {i j : Level} {A : UU i} {B : UU j} (f : A → B) →
  is-contr A → is-contr B → is-equiv f
is-equiv-is-contr {i} {j} {A} {B} f CA CB =
  pair
    (dpair
      (const B A (center CA))
      (sing-ind-is-contr B CB _ (inv (contraction CB (f (center CA))))))
    (dpair (const B A (center CA)) (contraction CA)) 

-- Exercise 6.4

-- In this exercise we will show that if the base type in a Σ-type is contractible, then the Σ-type is equivalent to the fiber at the center of contraction. This can be seen as a left unit law for Σ-types. We will derive a right unit law for Σ-types in Lecture 7 (not because it is unduable here, but it is useful to have some knowledge of fiberwise equivalences).

left-unit-law-Σ-map : {i j : Level} {C : UU i} (B : C → UU j)
  (H : is-contr C) → B (center H) → Σ C B
left-unit-law-Σ-map B H y = dpair (center H) y

left-unit-law-Σ-map-conv : {i j : Level} {C : UU i} (B : C → UU j)
  (H : is-contr C) → Σ C B → B (center H)
left-unit-law-Σ-map-conv B H =
  ind-Σ (sing-ind-is-contr _ H (λ x → B x → B (center H)) id)

left-inverse-left-unit-law-Σ-map-conv : {i j : Level} {C : UU i}
  (B : C → UU j) (H : is-contr C) →
  ((left-unit-law-Σ-map-conv B H) ∘ (left-unit-law-Σ-map B H)) ~ id
left-inverse-left-unit-law-Σ-map-conv B H y =
  ap
    ( λ (f : B (center H) → B (center H)) → f y)
    ( sing-comp-is-contr _ H (λ x → B x → B (center H)) id)

right-inverse-left-unit-law-Σ-map-conv : {i j : Level} {C : UU i}
  (B : C → UU j) (H : is-contr C) →
  ((left-unit-law-Σ-map B H) ∘ (left-unit-law-Σ-map-conv B H)) ~ id
right-inverse-left-unit-law-Σ-map-conv B H =
  ind-Σ
    ( sing-ind-is-contr _ H
      ( λ x → (y : B x) →
        Id
          ( (left-unit-law-Σ-map B H ∘ left-unit-law-Σ-map-conv B H)
 (dpair x y))
          ( id (dpair x y)))
      ( λ y → ap
        ( left-unit-law-Σ-map B H)
        ( ap
          ( λ f → f y)
          ( sing-comp-is-contr _ H (λ x → B x → B (center H)) id))))

is-equiv-left-unit-law-Σ-map : {i j : Level} {C : UU i}
  (B : C → UU j) (H : is-contr C) → is-equiv (left-unit-law-Σ-map B H)
is-equiv-left-unit-law-Σ-map B H =
  pair
    ( dpair
      ( left-unit-law-Σ-map-conv B H)
      ( right-inverse-left-unit-law-Σ-map-conv B H))
    ( dpair
      ( left-unit-law-Σ-map-conv B H)
      ( left-inverse-left-unit-law-Σ-map-conv B H))

left-unit-law-Σ : {i j : Level} {C : UU i} (B : C → UU j) (H : is-contr C) →
  B (center H) ≃ Σ C B
left-unit-law-Σ B H =
  dpair (left-unit-law-Σ-map B H) (is-equiv-left-unit-law-Σ-map B H)

-- Exercise 6.5

-- In this exercise we simply compute the transport in the fiber of a map.
tr-fiber : {i j : Level} {A : UU i} {B : UU j}
  (f : A → B) {x y : B} (p : Id x y) (a : A) (q : Id (f a) x) →
  Id (tr (fib f) p (dpair a q)) (dpair a (concat x q p))
tr-fiber f refl a refl = refl

-- Exercise 6.6

-- In this exercise we show that the domain of a map is equivalent to the total space of its fibers.

Σ-fib-to-domain : {i j : Level} {A : UU i} {B : UU j} (f : A → B ) →
  (Σ B (fib f)) → A
Σ-fib-to-domain f (dpair y (dpair x p)) = x

triangle-Σ-fib-to-domain : {i j : Level} {A : UU i} {B : UU j} (f : A → B ) →
  pr1 ~ (f ∘ (Σ-fib-to-domain f))
triangle-Σ-fib-to-domain f (dpair y (dpair x p)) = inv p

domain-to-Σ-fib : {i j : Level} {A : UU i} {B : UU j} (f : A → B) →
  A → Σ B (fib f)
domain-to-Σ-fib f x = dpair (f x) (dpair x refl)

left-inverse-domain-to-Σ-fib : {i j : Level} {A : UU i} {B : UU j}
  (f : A → B ) → ((domain-to-Σ-fib f) ∘ (Σ-fib-to-domain f)) ~ id
left-inverse-domain-to-Σ-fib f (dpair .(f x) (dpair x refl)) = refl

right-inverse-domain-to-Σ-fib : {i j : Level} {A : UU i} {B : UU j}
  (f : A → B ) → ((Σ-fib-to-domain f) ∘ (domain-to-Σ-fib f)) ~ id
right-inverse-domain-to-Σ-fib f x = refl

is-equiv-Σ-fib-to-domain : {i j : Level} {A : UU i} {B : UU j}
  (f : A → B ) → is-equiv (Σ-fib-to-domain f)
is-equiv-Σ-fib-to-domain f =
  pair
    ( dpair (domain-to-Σ-fib f) (right-inverse-domain-to-Σ-fib f))
    ( dpair (domain-to-Σ-fib f) (left-inverse-domain-to-Σ-fib f))

equiv-Σ-fib-to-domain : {i j : Level} {A : UU i} {B : UU j}
  (f : A → B ) → Σ B (fib f) ≃ A
equiv-Σ-fib-to-domain f =
  dpair (Σ-fib-to-domain f) (is-equiv-Σ-fib-to-domain f)

-- Exercise 6.7

-- In this exercise we show that if a cartesian product is contractible, then so are its factors. We make use of the fact that contractible types are closed under retracts, just because that is a useful property to practice with. Other proofs are possible too.

is-contr-left-factor-prod : {i j : Level} (A : UU i) (B : UU j) →
  is-contr (A × B) → is-contr A
is-contr-left-factor-prod A B H =
  is-contr-retract-of
    ( A × B)
    ( dpair (λ x → pair x (pr2 (center H))) (dpair pr1 (λ x → refl)))
    ( H)

is-contr-right-factor-prod : {i j : Level} (A : UU i) (B : UU j) →
  is-contr (A × B) → is-contr B
is-contr-right-factor-prod A B H =
  is-contr-left-factor-prod B A
    ( is-contr-is-equiv (A × B) (swap-prod B A) (is-equiv-swap-prod B A) H)

is-contr-prod : {i j : Level} {A : UU i} {B : UU j} →
  is-contr A → is-contr B → is-contr (A × B)
is-contr-prod {A = A} {B = B} is-contr-A is-contr-B =
  is-contr-is-equiv' B
    ( left-unit-law-Σ-map (λ x → B) is-contr-A)
    ( is-equiv-left-unit-law-Σ-map (λ x → B) is-contr-A)
    ( is-contr-B)

-- Exercise 6.8

-- Given any family B over A, there is a map from the fiber of the projection map (pr1 : Σ A B → A) to the type (B a), i.e. the fiber of B at a. In this exercise we define this map, and show that it is an equivalence, for every a : A.

fib-fam-fib-pr1 : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → fib (pr1 {i} {j} {A} {B}) a → B a
fib-fam-fib-pr1 B a (dpair (dpair x y) p) = tr B p y

fib-pr1-fib-fam : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → B a → fib (pr1 {i} {j} {A} {B}) a
fib-pr1-fib-fam B a b = dpair (dpair a b) refl

left-inverse-fib-pr1-fib-fam : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → ((fib-pr1-fib-fam B a) ∘ (fib-fam-fib-pr1 B a)) ~ id
left-inverse-fib-pr1-fib-fam B a (dpair (dpair .a y) refl) = refl

right-inverse-fib-pr1-fib-fam : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → ((fib-fam-fib-pr1 B a) ∘ (fib-pr1-fib-fam B a)) ~ id
right-inverse-fib-pr1-fib-fam B a b = refl

is-equiv-fib-fam-fib-pr1 : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → is-equiv (fib-fam-fib-pr1 B a)
is-equiv-fib-fam-fib-pr1 B a =
  pair
    ( dpair (fib-pr1-fib-fam B a) (right-inverse-fib-pr1-fib-fam B a))
    ( dpair (fib-pr1-fib-fam B a) (left-inverse-fib-pr1-fib-fam B a))

is-equiv-fib-pr1-fib-fam : {i j : Level} {A : UU i} (B : A → UU j)
  (a : A) → is-equiv (fib-pr1-fib-fam B a)
is-equiv-fib-pr1-fib-fam B a =
  pair
    ( dpair (fib-fam-fib-pr1 B a) (left-inverse-fib-pr1-fib-fam B a))
    ( dpair (fib-fam-fib-pr1 B a) (right-inverse-fib-pr1-fib-fam B a))

is-equiv-pr1-is-contr : {i j : Level} {A : UU i} (B : A → UU j) →
  ((a : A) → is-contr (B a)) → is-equiv (pr1 {i} {j} {A} {B})
is-equiv-pr1-is-contr B H =
  is-equiv-is-contr-map
    ( λ x → is-contr-is-equiv
      ( B x)
      ( fib-fam-fib-pr1 B x)
      ( is-equiv-fib-fam-fib-pr1 B x)
      ( H x))

is-contr-is-equiv-pr1 : {i j : Level} {A : UU i} (B : A → UU j) →
  (is-equiv (pr1 {i} {j} {A} {B})) → ((a : A) → is-contr (B a))
is-contr-is-equiv-pr1 B H a =
  is-contr-is-equiv'
    ( fib pr1 a)
    ( fib-fam-fib-pr1 B a)
    ( is-equiv-fib-fam-fib-pr1 B a)
    ( is-contr-map-is-equiv H a)

right-unit-law-Σ : {i j : Level} {A : UU i} (B : A → UU j) →
  ((a : A) → is-contr (B a)) → (Σ A B) ≃ A
right-unit-law-Σ B H =
  dpair
    ( pr1)
    ( is-equiv-pr1-is-contr B H)

\end{code}
