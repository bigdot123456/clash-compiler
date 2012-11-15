{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module CLaSH.Netlist.Types where

import Control.Monad.State     (MonadIO,MonadState,StateT)
import Data.ByteString.Lazy    (ByteString)
import Data.Text.Lazy          (Text)
import Data.HashMap.Lazy       (HashMap)
import Unbound.LocallyNameless (Fresh,FreshMT)

import CLaSH.Core.Term (Term,TmName)
import CLaSH.Core.Type (Type)
import CLaSH.Core.Util (Gamma)
import CLaSH.Primitives.Types (Primitive)
import CLaSH.Util

newtype NetlistMonad a =
    NetlistMonad { runNetlist :: StateT NetlistState (FreshMT IO) a }
  deriving (Functor, Monad, Applicative, MonadState NetlistState, Fresh, MonadIO)

data NetlistState
  = NetlistState
  { _bindings   :: HashMap TmName (Type,Term)
  , _varEnv     :: Gamma
  , _varCount   :: Integer
  , _cmpCount   :: Integer
  , _components :: HashMap TmName Component
  , _primitives :: HashMap ByteString Primitive
  }

type Identifier = Text
type Label      = Identifier

data Component
  = Component
  { componentName :: Identifier
  , inputs        :: [(Identifier,HWType)]
  , output        :: (Identifier,HWType)
  , declarations  :: [Declaration]
  }
  deriving Show

type Size = Int

data HWType
  = Bit
  | Bool
  | Integer
  | Signed   Size
  | Unsigned Size
  | Vector   Size       HWType
  | Sum      Identifier [Identifier]
  | Product  Identifier [HWType]
  | SP       Identifier [(Identifier,[HWType])]
  deriving Show

data Declaration
  = Assignment Identifier (Maybe Modifier) HWType [Expr]
  | InstDecl Identifier Identifier [(Identifier,Expr)]
  | BlackBox ByteString
  | NetDecl Identifier HWType (Maybe Expr)
  deriving Show

data Modifier
  = Indexed  Int
  | Selected Label
  | DC Int
  deriving Show

data Expr
  = Literal    (Maybe Size) Literal
  | Identifier Identifier   (Maybe Modifier)
  deriving Show

data Literal
  = NumLit  Int
  | BitLit  Bit
  | BoolLit Bool
  | VecLit  [Literal]
  deriving Show

data Bit = H | L | U | Z
  deriving Show

mkLabels [''NetlistState]
