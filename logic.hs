import Data.List
import Control.Monad

type V = Char
data P = Var V | Not P | And P P | Or P P | Then P P | Iff P P | T | F
         deriving (Show, Eq)

data Truth = Contradiction | Contingency | Tautology
             deriving (Show, Eq)     
             
type Proof = [P]

-- Evaluates the proposition
-- All vars should be replaced when using this function
eval :: P -> Bool
eval T         = True
eval F         = False
eval (Not p)   = not (eval p)
eval (And p q) = (eval p) && (eval q)
eval (Or p q)  = (eval p) || (eval q)
eval (Then p q)= (not (eval p)) || (eval q)
eval (Iff p q) = eval p == eval q
--eval (Var x) = should not happen

 
-- This replaces a variable with an expression (actually just True or False)
replace :: P -> [(Char, P)] -> P
replace T r         = T
replace F r         = F
replace (Not p) r   = Not (replace p r)
replace (And p q) r = And (replace p r) (replace q r)
replace (Or p q) r  = Or (replace p r) (replace q r)
replace (Then p q) r= Then (replace p r) (replace q r)
replace (Iff p q) r = Iff (replace p r) (replace q r)
replace (Var x) r   | (x, T) `elem` r = T
                    | (x, F) `elem` r = F
                    | otherwise       = Var x


-- This function is used to get all the variables in the proposition.
-- The vars function removes the duplicates generated in vars' function.
vars' :: P  -> [Char]
vars' T         = []
vars' F         = []
vars' (Not p)   = (vars' p)
vars' (And p q) = (vars' p)++(vars' q)
vars' (Or p q)  = (vars' p)++(vars' q)
vars' (Then p q)= (vars' p)++(vars' q)
vars' (Iff p q) = (vars' p)++(vars' q)
vars' (Var x)   = [x]

vars :: P -> [Char]
vars p = (map head . group . sort) (vars' p)

-- This will be used to make the truth table, as I need all the combinations
-- of the truth value of the variables.
-- http://stackoverflow.com/questions/9658409/haskell-combinations-and-permutation
allCombinations :: Int -> [[P]]
allCombinations n = replicateM n [T, F]

truthTable :: P -> [Bool]
truthTable p = [eval (replace p (zip v comb)) | comb <- allCombinations (length v)] 
               where v = vars p
              
truth :: P -> Truth
truth p | all id (truthTable p) = Tautology
        | any id (truthTable p) = Contingency
        | otherwise             = Contradiction


areEquivalent :: P -> P -> Bool
areEequivalent p q = truth (Iff p q) == Tautology


-- abides by the law that:
-- areEquivalent p (reduce p)
reduce :: P -> P
reduce T       = T
reduce F       = F
reduce (Var x) = Var x
reduce (Not (Not p))            = reduce p
reduce (And (Then p q) a)       = if p == a then reduce q else (And (Then (reduce p) (reduce q)) (reduce a))
--reduce (And (Then p q) (Not q)) = reduce (Not p)

{-
--prove :: P -> Proof
-}
