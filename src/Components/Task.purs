module Components.Task where

import Prelude

import Data.Lens
import Data.List
import Data.Tuple
import Data.Either
import Data.Foldable (fold)

import Control.Monad.Eff
import Control.Monad.Eff.Unsafe

import Node.UUID (UUID())

import qualified Thermite as T

import qualified React as R
import qualified React.DOM as R
import qualified React.DOM.Props as RP

import Unsafe.Coerce

-- | Actions for the task component
data TaskAction
  = ChangeCompleted Boolean
  | RemoveTask

-- | The state for the task component
type Task =
  { id :: UUID
  , completed :: Boolean
  , description :: String
  }

initialTask :: UUID -> String -> Task
initialTask u s = { id: u, completed: false, description: s }

-- | A `Spec` for the task component.
taskSpec :: forall eff props. T.Spec eff Task props TaskAction
taskSpec = T.simpleSpec performAction render
  where
  -- Renders the current state of the component as a collection of React elements.
  render :: T.Render Task props TaskAction
  render dispatch _ s _ =
    [ (R.tr [ RP.key $ show s.id ]) <<< map (R.td' <<< pure) $
        [ R.input [ RP._type "checkbox"
                  , RP.className "checkbox"
                  , RP.checked (if s.completed then "checked" else "")
                  , RP.title "Mark as completed"
                  , RP.onChange \e -> dispatch (ChangeCompleted (unsafeCoerce e).target.checked)
                  ] []
        , R.text s.description
        , R.a [ RP.className "btn btn-danger pull-right"
              , RP.title "Remove item"
              , RP.onClick \_ -> dispatch RemoveTask
              ]
              [ R.text "✖" ]
        ]
    ]

  -- Updates the state in response to an action.
  --
  -- _Note_: this component can only see actions of type `TaskAction`, but the `RemoveTask` action
  -- is ignored here: it will be handled by the parent component.
  performAction :: T.PerformAction eff Task props TaskAction
  performAction (ChangeCompleted b)   _ state k = k $ state { completed = b }
  performAction _                     _ _ _ = pure unit
