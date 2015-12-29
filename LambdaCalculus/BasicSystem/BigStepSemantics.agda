module BasicSystem.BigStepSemantics where
open import BasicSystem.Syntax
open import BasicSystem.OPE

mutual
  data eval_&_⇓_ : ∀ {Γ Δ σ} → Tm Δ σ → Env Γ Δ → Val Γ σ → Set where
    rlam  : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs : Env Γ Δ} →
            eval λt t & vs ⇓ λv t vs
    rvar  : ∀ {Γ Δ σ}{vs : Env Γ Δ}{v : Val Γ σ} → 
            eval top & (vs << v) ⇓ v
    rsubs : ∀ {B Γ Δ σ}{t : Tm Δ σ}{ts : Sub Γ Δ}{vs : Env B Γ}{ws v} →
            evalˢ ts & vs ⇓ ws → eval t & ws ⇓ v → eval t [ ts ] & vs ⇓ v
    rapp  : ∀ {Γ Δ σ τ}{t : Tm Δ (σ ⇒ τ)}{u : Tm Δ σ}{vs : Env Γ Δ}
            {f : Val Γ (σ ⇒ τ)}{a : Val Γ σ}{v : Val Γ τ} →
            eval t & vs ⇓ f → eval u & vs ⇓ a → f $$ a ⇓ v →
            eval t $ u & vs ⇓ v

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
    qarr : ∀ {Γ σ τ}{f : Val Γ (σ ⇒ τ)}{v : Val (Γ < σ) τ}{n} →
           vwk σ f $$ nev (varV vZ) ⇓ v →  quot v ⇓ n → quot f ⇓ λn n
    qbase : ∀ {Γ}{m : NeV Γ ι}{n} → quotⁿ m ⇓ n → quot nev m ⇓ ne n

  data quotⁿ_⇓_ : ∀ {Γ σ} → NeV Γ σ → NeN Γ σ → Set where
    qⁿvar : ∀ {Γ σ}{x : Var Γ σ} → quotⁿ varV x ⇓ varN x
    qⁿapp : ∀ {Γ σ τ}{m : NeV Γ (σ ⇒ τ)}{v}{n}{n'} →
            quotⁿ m ⇓ n → quot v ⇓ n' → quotⁿ appV m v ⇓ appN n n'

open import BasicSystem.IdentityEnvironment

data nf_⇓_ {Γ : Con}{σ : Ty} : Tm Γ σ → Nf Γ σ → Set where
  norm⇓ : ∀ {t v n} → eval t & vid ⇓ v → quot v ⇓ n → nf t ⇓ n