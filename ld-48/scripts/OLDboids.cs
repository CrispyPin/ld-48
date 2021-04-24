using Godot;
using System;



public class boids : Node
{
    Node boid;
    
    /*[Export] 
    public string str;
    
    [Export] 
    public Node boidScene;
    
    [Export]
    private NodePath _nodePath;*/
    public override void _Ready()
    {
        boid = (PackedScene)ResourceLoader.Load("res://scenes/boid.tscn");
        AddChild(boid.Instance());
        AddChild(boid.Instance());
        AddChild(boid.Instance());
        AddChild(boid.Instance());
    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
