enum Team {
    Any = 1,
    Zombie = 2,
    Human = 3
}

enum GameEvent {
    RoundStart,
    PlayerSpawn,
    PlayerDeath
}

enum ParkourPart { // Add new parts at the end pls
    Shrine = 0,
    Platform = 1,
    Wall = 2
}

enum MinigameStatus {
    None,
    InProgress,
    Completed,
    Failed
}

enum NinesEnemyAi {
    None,
    FollowPlayer,
    Bounce
}

enum NinesEnemyShootingPattern {
    SlowStraight,
    FastStraight,
    SlowCross,
    FastCross,
}