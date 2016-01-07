module FiniteProducts.BigStepSemantics where

open import FiniteProducts.Syntax
open import FiniteProducts.OPE

mutual
  data eval_&_⇓_ : ∀ {Γ Δ σ} → Tm Δ σ → Env Γ Δ → Val Γ σ → Set where
    rvar  : ∀ {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} → 
            eval ø & (vs << v) ⇓ v
    rsubs : ∀ {B Γ Δ σ}{t : Tm Δ σ}{ts : Sub Γ Δ}{vs : Env B Γ}{ws v} →
            evalˢ ts & vs ⇓ ws → eval t & ws ⇓ v → eval t [ ts ] & vs ⇓ v
    rlam  : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ} →
            eval ƛ t & vs ⇓ λv t vs
    rapp  : ∀ {Γ Δ σ τ}{t : Tm Δ (σ ⇒ τ)}{u : Tm Δ σ}{vs : Env Γ Δ}
            {f : Val Γ (σ ⇒ τ)}{a : Val Γ σ}{v : Val Γ τ} →
            eval t & vs ⇓ f → eval u & vs ⇓ a → f ∙∙ a ⇓ v →
            eval t ∙ u & vs ⇓ v
    rvoid : ∀ {Γ Δ}{vs : Env Γ Δ} → eval void & vs ⇓ voidv
    r<,>  : ∀ {Γ Δ σ τ}{t : Tm Δ σ}{u : Tm Δ τ}{vs : Env Γ Δ}
            {v : Val Γ σ}{w : Val Γ τ} → eval t & vs ⇓ v → eval u & vs ⇓ w →
            eval < t , u > & vs ⇓ < v , w >v
    rfst  : ∀ {Γ Δ σ τ}{t : Tm Δ (σ * τ)}{vs : Env Γ Δ}
            {v : Val Γ (σ * τ)} → eval t & vs ⇓ v →
            {w : Val Γ σ} → vfst v ⇓ w → eval fst t & vs ⇓ w 
    rsnd  : ∀ {Γ Δ σ τ}{t : Tm Δ (σ * τ)}{vs : Env Γ Δ}
            {v : Val Γ (σ * τ)} → eval t & vs ⇓ v → 
            {w : Val Γ τ} → vsnd v ⇓ w → eval snd t & vs ⇓ w 

  data vfst_⇓_ : ∀ {Γ σ τ} → Val Γ (σ * τ) → Val Γ σ → Set where
    rfst<,> : ∀ {Γ σ τ}{v : Val Γ σ}{w : Val Γ τ} → vfst < v , w >v ⇓ v
    rfstnev : ∀ {Γ σ τ}{n : NeV Γ (σ * τ)} → vfst nev n ⇓ nev (fstV n) 

  data vsnd_⇓_ : ∀ {Γ σ τ} → Val Γ (σ * τ) → Val Γ τ → Set where
    rsnd<,> : ∀ {Γ σ τ}{v : Val Γ σ}{w : Val Γ τ} → vsnd < v , w >v ⇓ w
    rsndnev : ∀ {Γ σ τ}{n : NeV Γ (σ * τ)} → vsnd nev n ⇓ nev (sndV n) 

  data _∙∙_⇓_ : ∀ {Γ σ τ} → 
                Val Γ (σ ⇒ τ) → Val Γ σ → Val Γ τ → Set where
    r∙lam : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ}{a : Val Γ σ}{v} →
            eval t & vs << a ⇓ v → λv t vs ∙∙ a ⇓ v
    r∙ne  : ∀ {Γ σ τ}{n : NeV Γ (σ ⇒ τ)}{v : Val Γ σ} →
            nev n ∙∙ v ⇓ nev (appV n v)

  data evalˢ_&_⇓_ : ∀ {Γ Δ Σ} → 
                    Sub Δ Σ → Env Γ Δ → Env Γ Σ → Set where
    rˢ↑  : ∀ {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} → 
             evalˢ ↑ σ & vs << v ⇓ vs
    rˢcons : ∀ {Γ Δ Σ σ}{ts : Sub Δ Σ}{t : Tm Δ σ}{vs : Env Γ Δ}{ws v} →
             evalˢ ts & vs ⇓ ws → eval t & vs ⇓ v → 
             evalˢ ts < t & vs ⇓ (ws << v)
    rˢid   : ∀ {Γ Δ}{vs : Env Γ Δ} → evalˢ ı & vs ⇓ vs
    rˢcomp : ∀ {A B Γ Δ}{ts : Sub Γ Δ}{us : Sub B Γ}{vs : Env A B}{ws}
                    {xs} → evalˢ us & vs ⇓ ws →
                    evalˢ ts & ws ⇓ xs → evalˢ ts ○ us & vs ⇓ xs

mutual
  data quot_⇓_ : ∀ {Γ σ} → Val Γ σ → Nf Γ σ → Set where
    qbase  : ∀ {Γ}{m : NeV Γ ⋆}{n} → quotⁿ m ⇓ n → quot nev m ⇓ ne n
    qarr   : ∀ {Γ σ τ}{f : Val Γ (σ ⇒ τ)}{v : Val (Γ < σ) τ}{n} →
             vwk σ f ∙∙ nev (varV vZ) ⇓ v →  quot v ⇓ n → quot f ⇓ λn n
    qone   : ∀ {Γ}{v : Val Γ One} → quot v ⇓ voidn
    qprod  : ∀ {Γ σ τ}{p : Val Γ (σ * τ)}
             {v : Val Γ σ} → vfst p ⇓ v → {m : Nf Γ σ} → quot v ⇓ m →
             {w : Val Γ τ} → vsnd p ⇓ w → {n : Nf Γ τ} → quot w ⇓ n →
             quot p ⇓ < m , n >n

  data quotⁿ_⇓_ : ∀ {Γ σ} → NeV Γ σ → NeN Γ σ → Set where
    qⁿvar : ∀ {Γ σ}{x : Var Γ σ} → quotⁿ varV x ⇓ varN x
    qⁿapp : ∀ {Γ σ τ}{m : NeV Γ (σ ⇒ τ)}{v}{n}{n'} →
            quotⁿ m ⇓ n → quot v ⇓ n' → quotⁿ appV m v ⇓ appN n n'
    qⁿfst : ∀ {Γ σ τ}{m : NeV Γ (σ * τ)}{n : NeN Γ (σ * τ)} →
            quotⁿ m ⇓ n → quotⁿ fstV m ⇓ fstN n
    qⁿsnd : ∀ {Γ σ τ}{m : NeV Γ (σ * τ)}{n : NeN Γ (σ * τ)} →
            quotⁿ m ⇓ n → quotⁿ sndV m ⇓ sndN n

open import FiniteProducts.IdentityEnvironment

data nf_⇓_ {Γ : Con}{σ : Ty} : Tm Γ σ → Nf Γ σ → Set where
  norm⇓ : ∀ {t v n} → eval t & vid ⇓ v → quot v ⇓ n → nf t ⇓ n
