module NaturalNumbers.BigStepSemantics where
open import NaturalNumbers.Syntax
open import NaturalNumbers.OPE

mutual
  data eval_&_⇓_ : ∀ {Γ Δ σ} → Tm Δ σ → Env Γ Δ → Val Γ σ → Set where
    rvar  : ∀ {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} → 
            eval top & (vs << v) ⇓ v
    rsubs : ∀ {B Γ Δ σ}{t : Tm Δ σ}{ts : Sub Γ Δ}{vs : Env B Γ}{ws v} →
            evalˢ ts & vs ⇓ ws → eval t & ws ⇓ v → eval t [ ts ] & vs ⇓ v
    rlam  : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ} →
            eval λt t & vs ⇓ λv t vs
    rapp  : ∀ {Γ Δ σ τ}{t : Tm Δ (σ ⇒ τ)}{u : Tm Δ σ}{vs : Env Γ Δ}
            {f : Val Γ (σ ⇒ τ)}{a : Val Γ σ}{v : Val Γ τ} →
            eval t & vs ⇓ f → eval u & vs ⇓ a → f $$ a ⇓ v →
            eval t $ u & vs ⇓ v
    rzero : ∀ {Γ Δ}{vs : Env Γ Δ} → eval zero & vs ⇓ zerov
    rsuc  : ∀ {Γ Δ}{t : Tm Δ N}{vs : Env Γ Δ}{v : Val Γ N} →
            eval t & vs ⇓ v → eval suc t & vs ⇓ sucv v
    rprim : ∀ {Γ Δ σ}{z : Tm Δ σ}{s t}{vs : Env Γ Δ}{z' s' v} →
            eval z & vs ⇓ z' → eval s & vs ⇓ s' → eval t & vs ⇓ v →
            {w : Val Γ σ} → prim z' & s' & v ⇓ w → eval prim z s t & vs ⇓ w

  data prim_&_&_⇓_ : ∀ {Γ σ} → Val Γ σ → Val Γ (N ⇒ σ ⇒ σ) → Val Γ N →
                     Val Γ σ → Set where
    rprn : ∀ {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)}{n : NeV Γ N} →
           prim z & s & nev n ⇓ nev (primV z s n)
    rprz : ∀ {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)} →
           prim z & s & zerov ⇓ z
    rprs : ∀ {Γ σ}{z : Val Γ σ}{s : Val Γ (N ⇒ σ ⇒ σ)}{v : Val Γ N} →
           {f : Val Γ (σ ⇒ σ)} → s $$ v ⇓ f → 
           {w : Val Γ σ} → prim z & s & v ⇓ w → 
           {w' : Val Γ σ} → f $$ w ⇓ w' →
           prim z & s & sucv v ⇓ w'
           
  data _$$_⇓_ : ∀ {Γ σ τ} → 
                Val Γ (σ ⇒ τ) → Val Γ σ → Val Γ τ → Set where
    r$lam : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ}{a : Val Γ σ}{v} →
            eval t & vs << a ⇓ v → λv t vs $$ a ⇓ v
    r$ne  : ∀ {Γ σ τ}{n : NeV Γ (σ ⇒ τ)}{v : Val Γ σ} →
            nev n $$ v ⇓ nev (appV n v)

  data evalˢ_&_⇓_ : ∀ {Γ Δ Σ} → 
                    Sub Δ Σ → Env Γ Δ → Env Γ Σ → Set where
    rˢpop  : ∀ {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} → 
             evalˢ pop σ & vs << v ⇓ vs
    rˢcons : ∀ {Γ Δ Σ σ}{ts : Sub Δ Σ}{t : Tm Δ σ}{vs : Env Γ Δ}{ws v} →
             evalˢ ts & vs ⇓ ws → eval t & vs ⇓ v → 
             evalˢ ts < t & vs ⇓ (ws << v)
    rˢid   : ∀ {Γ Δ}{vs : Env Γ Δ} → evalˢ id & vs ⇓ vs
    rˢcomp : ∀ {A B Γ Δ}{ts : Sub Γ Δ}{us : Sub B Γ}{vs : Env A B}{ws}
                    {xs} → evalˢ us & vs ⇓ ws →
                    evalˢ ts & ws ⇓ xs → evalˢ ts ○ us & vs ⇓ xs

mutual
  data quot_⇓_ : ∀ {Γ σ} → Val Γ σ → Nf Γ σ → Set where
    qbase : ∀ {Γ}{m : NeV Γ ι}{n} → quotⁿ m ⇓ n → quot nev m ⇓ neι n
    qarr  : ∀ {Γ σ τ}{f : Val Γ (σ ⇒ τ)}{v : Val (Γ < σ) τ}{n} →
            vwk σ f $$ nev (varV vZ) ⇓ v →  quot v ⇓ n → quot f ⇓ λn n
    qNz   : ∀ {Γ} → quot zerov {Γ} ⇓ zeron
    qNs   : ∀ {Γ}{v : Val Γ N}{n : Nf Γ N} → quot v ⇓ n →
            quot sucv v ⇓ sucn n 
    qNn   : ∀ {Γ}{n : NeV Γ N}{n' : NeN Γ N} → quotⁿ n ⇓ n' →
            quot nev n ⇓ neN n'

  data quotⁿ_⇓_ : ∀ {Γ σ} → NeV Γ σ → NeN Γ σ → Set where
    qⁿvar  : ∀ {Γ σ}{x : Var Γ σ} → quotⁿ varV x ⇓ varN x
    qⁿapp  : ∀ {Γ σ τ}{m : NeV Γ (σ ⇒ τ)}{v}{n}{n'} →
             quotⁿ m ⇓ n → quot v ⇓ n' → quotⁿ appV m v ⇓ appN n n'
    qⁿprim : ∀ {Γ σ}{z : Val Γ σ}{s n z' s' n'} → quot z ⇓ z' →
             quot s ⇓ s' → quotⁿ n ⇓ n' → 
             quotⁿ primV z s n ⇓ primN z' s' n'

open import NaturalNumbers.IdentityEnvironment

data nf_⇓_ {Γ : Con}{σ : Ty} : Tm Γ σ → Nf Γ σ → Set where
  norm⇓ : ∀ {t v n} → eval t & vid ⇓ v → quot v ⇓ n → nf t ⇓ n