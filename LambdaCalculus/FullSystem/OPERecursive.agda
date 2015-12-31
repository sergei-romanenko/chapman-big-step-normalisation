{-# OPTIONS --no-termination-check #-}
module FullSystem.OPERecursive where
open import FullSystem.Utils
open import FullSystem.Syntax
open import FullSystem.OPE
open import FullSystem.OPELemmas
open import FullSystem.RecursiveNormaliser

-- Unsurprisingly this isn't structurally recursive

mutual
  evmaplem : ∀ {B Γ Δ σ}(f : OPE B Γ)(t : Tm Δ σ)(vs : Env Γ Δ) → 
             eval t (emap f vs) ≡ vmap f (eval t vs)
  evmaplem f top          (vs << v) = refl 
  evmaplem f (t [ ts ])   vs        = 
    trans (cong (eval t) (evˢmaplem f ts vs)) (evmaplem f t (evalˢ ts vs)) 
  evmaplem f (λt t)        vs        = refl 
  evmaplem f (t $ u)      vs        = 
    trans (cong₂ (λ v a → v $$ a) (evmaplem f t vs) (evmaplem f u vs))
           ($$maplem f (eval t vs) (eval u vs))
  evmaplem f zero         vs        = refl 
  evmaplem f (suc t)      vs        = cong sucv (evmaplem f t vs) 
  evmaplem f (prim z s t) vs        = 
    trans (cong₃ vprim (evmaplem f z vs) (evmaplem f s vs) (evmaplem f t vs)) 
           (primmaplem f (eval z vs) (eval s vs) (eval t vs))       
  evmaplem f void       vs        = refl 
  evmaplem f < t , u >  vs        = cong₂ <_,_>v (evmaplem f t vs) (evmaplem f u vs) 
  evmaplem f (fst t)    vs        = trans (cong vfst (evmaplem f t vs)) 
                                           (vfstmaplem f (eval t vs)) 
  evmaplem f (snd t)    vs        = trans (cong vsnd (evmaplem f t vs)) 
                                           (vsndmaplem f (eval t vs)) 

  vfstmaplem : ∀ {B Γ σ τ}(f : OPE B Γ)(v : Val Γ (σ × τ)) →
               vfst (vmap f v) ≡ vmap f (vfst v)
  vfstmaplem f < v , w >v = refl 
  vfstmaplem f (nev n)    = refl 

  vsndmaplem : ∀ {B Γ σ τ}(f : OPE B Γ)(v : Val Γ (σ × τ)) →
               vsnd (vmap f v) ≡ vmap f (vsnd v)
  vsndmaplem f < v , w >v = refl 
  vsndmaplem f (nev n)    = refl 

  primmaplem : ∀ {B Γ σ}(f : OPE B Γ)(z : Val Γ σ) s v → 
               vprim (vmap f z) (vmap f s) (vmap f v) ≡ vmap f (vprim z s v)
  primmaplem f z s (nev n)  = refl 
  primmaplem f z s zerov    = refl 
  primmaplem f z s (sucv v) = 
    trans (cong₂ _$$_ ($$maplem f s v) (primmaplem f z s v)) 
           ($$maplem f (s $$ v) (vprim z s v)) 

  $$maplem : ∀ {Γ Δ σ τ}(f : OPE Γ Δ)(v : Val Δ (σ ⇒ τ))(a : Val Δ σ) →
             vmap f v $$ vmap f a ≡ vmap f (v $$ a)
  $$maplem f (λv t vs) a = evmaplem f t (vs << a) 
  $$maplem f (nev n)   a = refl 

  evˢmaplem : ∀ {A B Γ Δ}(f : OPE A B)(ts : Sub Γ Δ)(vs : Env B Γ) →
              evalˢ ts (emap f vs) ≡ emap f (evalˢ ts vs)
  evˢmaplem f (pop σ)   (vs << v) = refl 
  evˢmaplem f (ts < t)  vs        = 
    cong₂ _<<_ (evˢmaplem f ts vs) (evmaplem f t vs) 
  evˢmaplem f id        vs        = refl 
  evˢmaplem f (ts ○ us) vs        = 
    trans (cong (evalˢ ts) (evˢmaplem f us vs)) 
           (evˢmaplem f ts (evalˢ us vs))  

mutual
  qmaplem : ∀ {Γ Δ σ}(f : OPE Γ Δ)(v : Val Δ σ) → 
             quot (vmap f v) ≡ nfmap f (quot v)
  qmaplem {σ = ι}     f (nev n) = cong neι (qⁿmaplem f n) 
  qmaplem {σ = σ ⇒ τ} f v       = 
    cong λn 
         (trans (cong (λ v → quot (v $$ nev (varV vZ))) 
                       (compvmap (skip σ oid) f v)) 
                 (trans (trans (cong (λ f → quot (vmap (skip σ f) v $$ nev (varV vZ))) 
                                       (trans (leftid f) (sym (rightid f))))
                                 (cong quot (trans (cong (λ v → v $$ nev (varV vZ))
                                                           (sym (compvmap (keep σ f) (skip σ oid) v)))  
                                                     ($$maplem (keep σ f) 
                                                               (vmap (skip σ oid) v) 
                                                               (nev (varV vZ)) ))))
                         (qmaplem (keep σ f)   
                                (vmap (skip σ oid) v $$ nev (varV vZ))))) 
  qmaplem {Γ} {Δ} {N} f (nev n) = cong neN (qⁿmaplem f n) 
  qmaplem {Γ} {Δ} {N} f zerov    = refl 
  qmaplem {Γ} {Δ} {N} f (sucv v) = cong sucn (qmaplem f v)  
  qmaplem {σ = One}   f v       = refl 
  qmaplem {σ = σ × τ} f v       = 
    cong₂ <_,_>n (trans (cong quot (vfstmaplem f v)) (qmaplem f (vfst v))) 
                 (trans  (cong quot (vsndmaplem f v)) (qmaplem f (vsnd v))) 

  qⁿmaplem : ∀ {Γ Δ σ}(f : OPE Γ Δ)(n : NeV Δ σ) → 
             quotⁿ (nevmap f n) ≡ nenmap f (quotⁿ n)
  qⁿmaplem f (varV x)      = refl 
  qⁿmaplem f (appV n v)    = cong₂ appN (qⁿmaplem f n) (qmaplem f v) 
  qⁿmaplem f (primV z s n) = 
    cong₃ primN (qmaplem f z) (qmaplem f s) (qⁿmaplem f n) 
  qⁿmaplem f (fstV n)   = cong fstN (qⁿmaplem f n) 
  qⁿmaplem f (sndV n)   = cong sndN (qⁿmaplem f n) 
