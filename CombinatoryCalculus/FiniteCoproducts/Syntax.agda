module FiniteCoproducts.Syntax where

-- Types
data Ty : Set where
  ι    : Ty
  _⇒_  : Ty → Ty → Ty
  Zero : Ty
  _+_  : Ty → Ty → Ty

infixr 50 _⇒_

-- Terms
data Tm : Ty → Set where
  K    : ∀ {σ τ} → Tm (σ ⇒ τ ⇒ σ)
  S    : ∀ {σ τ ρ} → Tm ((σ ⇒ τ ⇒ ρ) ⇒ (σ ⇒ τ) ⇒ σ ⇒ ρ)
  _$_  : ∀ {σ τ} → Tm (σ ⇒ τ) → Tm σ → Tm τ
  NE   : ∀ {σ} → Tm (Zero ⇒ σ) 
  inl  : ∀ {σ τ} → Tm (σ ⇒ (σ + τ))
  inr  : ∀ {σ τ} → Tm (τ ⇒ (σ + τ))
  C : ∀ {σ τ ρ} → Tm ((σ ⇒ ρ) ⇒ (τ ⇒ ρ) ⇒ (σ + τ) ⇒ ρ)

infixl 50 _$_

-- Definitional Equality
data _≡_ : ∀ {σ} → Tm σ → Tm σ → Set where
  refl  : ∀ {σ}{t : Tm σ} → t ≡ t
  sym   : ∀ {σ}{t t' : Tm σ} → t ≡ t' → t' ≡ t
  trans : ∀ {σ}{t t' t'' : Tm σ} → t ≡ t' → t' ≡ t'' → t ≡ t''
  K≡    : ∀ {σ τ}{x : Tm σ}{y : Tm τ} → K $ x $ y ≡ x
  S≡    : ∀ {σ τ ρ}{x : Tm (σ ⇒ τ ⇒ ρ)}{y : Tm (σ ⇒ τ)}{z : Tm σ} →
          S $ x $ y $ z ≡ x $ z $ (y $ z)
  $≡    : ∀ {σ}{τ}{t t' : Tm (σ ⇒ τ)}{u u' : Tm σ} → t ≡ t' → u ≡ u' →
          t $ u ≡ t' $ u'
  Cl : ∀ {σ τ ρ}{l : Tm (σ ⇒ ρ)}{r : Tm (τ ⇒ ρ)}{c : Tm σ} → C $ l $ r $ (inl $ c) ≡ l $ c
  Cr : ∀ {σ τ ρ}{l : Tm (σ ⇒ ρ)}{r : Tm (τ ⇒ ρ)}{c : Tm τ} → C $ l $ r $ (inr $ c) ≡ r $ c
  
-- Normal forms
data Nf : Ty → Set where
  Kⁿ   : ∀ {σ τ} → Nf (σ ⇒ τ ⇒ σ)
  Kⁿ¹  : ∀ {σ τ} → Nf σ → Nf (τ ⇒ σ)
  Sⁿ   : ∀ {σ τ ρ} → Nf ((σ ⇒ τ ⇒ ρ) ⇒ (σ ⇒ τ) ⇒ σ ⇒ ρ)
  Sⁿ¹  : ∀ {σ τ ρ} → Nf (σ ⇒ τ ⇒ ρ) → Nf ((σ ⇒ τ) ⇒ σ ⇒ ρ)
  Sⁿ²  : ∀ {σ τ ρ} → Nf (σ ⇒ τ ⇒ ρ) → Nf (σ ⇒ τ) → Nf (σ ⇒ ρ)
  NEⁿ  : ∀ {σ} → Nf (Zero ⇒ σ)
  inlⁿ  : ∀ {σ τ} → Nf (σ ⇒ (σ + τ))
  inlⁿ¹ : ∀ {σ τ} → Nf σ → Nf (σ + τ)
  inrⁿ  : ∀ {σ τ} → Nf (τ ⇒ (σ + τ))
  inrⁿ¹ : ∀ {σ τ} → Nf τ → Nf (σ + τ)
  Cⁿ : ∀ {σ τ ρ} → Nf ((σ ⇒ ρ) ⇒ (τ ⇒ ρ) ⇒ (σ + τ) ⇒ ρ)
  Cⁿ¹ : ∀ {σ τ ρ} → Nf (σ ⇒ ρ) → Nf ((τ ⇒ ρ) ⇒ (σ + τ) ⇒ ρ)
  Cⁿ² : ∀ {σ τ ρ} → Nf (σ ⇒ ρ) → Nf (τ ⇒ ρ) → Nf ((σ + τ) ⇒ ρ)

-- inclusion of normal forms in terms
⌜_⌝ : ∀ {σ} → Nf σ → Tm σ
⌜ Kⁿ      ⌝ = K
⌜ Kⁿ¹ x   ⌝ = K $ ⌜ x ⌝
⌜ Sⁿ      ⌝ = S
⌜ Sⁿ¹ x   ⌝ = S $ ⌜ x ⌝
⌜ Sⁿ² x y ⌝ = S $ ⌜ x ⌝ $ ⌜ y ⌝
⌜ NEⁿ     ⌝ = NE
⌜ inlⁿ¹ x ⌝ = inl $ ⌜ x ⌝
⌜ inlⁿ    ⌝ = inl
⌜ inrⁿ¹ x ⌝ = inr $ ⌜ x ⌝
⌜ inrⁿ    ⌝ = inr
⌜ Cⁿ      ⌝ = C
⌜ Cⁿ¹ l   ⌝ = C $ ⌜ l ⌝
⌜ Cⁿ² l r ⌝ = C $ ⌜ l ⌝ $ ⌜ r ⌝
