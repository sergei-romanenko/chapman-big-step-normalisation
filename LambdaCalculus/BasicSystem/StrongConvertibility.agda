module BasicSystem.StrongConvertibility where

open import BasicSystem.Utils
open import BasicSystem.Syntax
open import BasicSystem.OPE
open import BasicSystem.OPELemmas
open import BasicSystem.RecursiveNormaliser
open import BasicSystem.OPERecursive

_∼_ : ∀ {Γ σ} → Val Γ σ → Val Γ σ → Set 
_∼_ {Γ}{⋆}     (nev n) (nev n') = quotⁿ n ≡ quotⁿ n'   
_∼_ {Γ}{σ ⇒ τ} v       v'       = ∀ {B}(f : OPE B Γ){a a' : Val B σ} → 
    a ∼ a' → (vmap f v ∙∙ a) ∼ (vmap f v' ∙∙ a')

data _∼ˢ_ {Γ : Con} : ∀ {Δ} → Env Γ Δ → Env Γ Δ → Set where
  ∼ε  : ε ∼ˢ ε
  ∼<< : ∀ {Δ σ}{vs vs' : Env Γ Δ}{v v' : Val Γ σ} → 
        vs ∼ˢ vs' → v ∼ v' → (vs << v) ∼ˢ (vs' << v')

helper : ∀ {Θ}{σ}{τ}{f f' f'' f''' : Val Θ (σ ⇒ τ)} → 
         f ≡ f' → f'' ≡ f''' → {a a' : Val Θ σ} → 
         (f' ∙∙ a) ∼ (f''' ∙∙ a') → (f ∙∙ a) ∼ (f'' ∙∙ a')
helper refl refl p = p 

helper' : ∀ {Γ Δ σ τ}{t : Tm (Δ < σ) τ}{vs vs' vs'' : Env Γ Δ} → 
          vs'' ≡ vs' → {a a' : Val Γ σ} →          
          eval t (vs << a) ∼ eval t (vs' << a') → 
          eval t (vs << a) ∼ eval t (vs'' << a')
helper' refl p = p 

∼map : ∀ {Γ Δ σ}(f : OPE Γ Δ){v v' : Val Δ σ} → v ∼ v' →
       vmap f v ∼ vmap f v'
∼map {σ = ⋆}     f {nev n}{nev n'}  p = 
  trans (qⁿmaplem f n) (trans (cong (nenmap f) p) (sym (qⁿmaplem f n')) ) 
∼map {σ = σ ⇒ τ} f {v}    {v'}      p = λ f' p' → 
   helper (compvmap f' f v) (compvmap f' f v') (p (comp f' f) p')  

∼ˢmap : ∀ {B Γ Δ}(f : OPE B Γ){vs vs' : Env Γ Δ} → vs ∼ˢ vs' → 
        emap f vs ∼ˢ emap f vs'
∼ˢmap f ∼ε         = ∼ε 
∼ˢmap f (∼<< p p') = ∼<< (∼ˢmap f p) (∼map f p') 

mutual
  sym∼ : ∀ {Γ σ}{v v' : Val Γ σ} → v ∼ v' → v' ∼ v
  sym∼ {σ = ⋆}     {nev n}{nev n'} p = sym p 
  sym∼ {σ = σ ⇒ τ}                 p = λ f p' → sym∼ (p f (sym∼ p'))   


  sym∼ˢ : ∀ {Γ Δ}{vs vs' : Env Γ Δ} → vs ∼ˢ vs' → vs' ∼ˢ vs
  sym∼ˢ ∼ε        = ∼ε 
  sym∼ˢ (∼<< p q) = ∼<< (sym∼ˢ p) (sym∼ q)

mutual
  trans∼ : ∀ {Γ σ}{v v' v'' : Val Γ σ} → v ∼ v' → v' ∼ v'' → v ∼ v''
  trans∼ {σ = ⋆}     {nev n}{nev n'}{nev n''} p p' = trans p p' 
  trans∼ {σ = σ ⇒ τ}                          p p' = λ f p'' → 
    trans∼ (p f (trans∼ p'' (sym∼ p''))) (p' f p'')  

  -- using that if a is related to a' then a is related to a

  trans∼ˢ : ∀ {Γ Δ}{vs vs' vs'' : Env Γ Δ} → 
            vs ∼ˢ vs' → vs' ∼ˢ vs'' → vs ∼ˢ vs''
  trans∼ˢ ∼ε         ∼ε         = ∼ε 
  trans∼ˢ (∼<< p p') (∼<< q q') = ∼<< (trans∼ˢ p q) (trans∼ p' q')
