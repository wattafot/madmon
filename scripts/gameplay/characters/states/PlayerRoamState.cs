using Game.Core;
using Game.Utilities;
using Godot;

namespace Game.Gameplay;

public partial class PlayerRoamState : State
{
    [ExportCategory("State Vars")]
    [Export]
    public PlayerInput PlayerInput;

    [Export]
    public CharacterMovement CharacterMovement;

    public override void _Process(double delta)
    {
        GetInputDirection();
        GetInput(delta);
    }

    public void GetInputDirection()
    {
        if (Input.IsActionJustPressed("ui_up"))
        {
            PlayerInput.Direction = Vector2.Up;
            PlayerInput.TargetPosition = new Vector2(0, -Globals.Instance.GRID_SIZE);
        }
        else if (Input.IsActionJustPressed("ui_down"))
        {
            PlayerInput.Direction = Vector2.Down;
            PlayerInput.TargetPosition = new Vector2(0, Globals.Instance.GRID_SIZE);
        }
        else if (Input.IsActionJustPressed("ui_left"))
        {
            PlayerInput.Direction = Vector2.Left;
            PlayerInput.TargetPosition = new Vector2(-Globals.Instance.GRID_SIZE, 0);
        }
        else if (Input.IsActionJustPressed("ui_right"))
        {
            PlayerInput.Direction = Vector2.Right;
            PlayerInput.TargetPosition = new Vector2(Globals.Instance.GRID_SIZE, 0);
        }
    }

    public void GetInput(double delta)
    {
        if (CharacterMovement.IsMoving())
            return;

        if (Modules.IsActionJustReleased())
        {
            if (PlayerInput.HoldTime > PlayerInput.HoldThreshold)
            {
                PlayerInput.EmitSignal(CharacterInput.SignalName.Walk);
            }
            else
            {
                PlayerInput.EmitSignal(CharacterInput.SignalName.Turn);
            }

            PlayerInput.HoldTime = 0.0f;
        }

        if (Modules.IsActionPressed())
        {
            PlayerInput.HoldTime += delta;

            if (PlayerInput.HoldTime > PlayerInput.HoldThreshold)
            {
                PlayerInput.EmitSignal(CharacterInput.SignalName.Walk);
            }
        }
    }
}
