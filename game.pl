#!/usr/bin/perl

use Tk; 
require Tk; 

use strict; 
my $j = 0;
my $count = 0;
 
my $m;
my $c;
my $enemiesi; 
my $enemiesfirei; 
my $shotcount = 0;
my @shots; 
my $firei; 
my @e;
my $active = "Available"; 

my $lastkey = 'd'; 
my $fincount = 0;
my $player = initplayer(); 
srand();
init (); 


sub init {
    $m = new MainWindow(-title=>'Flatland 2');
    $m -> resizable (0,0);
    $m -> bind ('<a>', \&playerleft);
    $m -> bind ('<s>', \&playerdown);
    $m -> bind ('<w>', \&playerup);
    $m -> bind ('<d>', \&playerright);
    $m -> bind ('<e>', \&fire);
    
    $c = $m -> Canvas (-width=>500, -height=>500, -background=>'yellow') -> pack ();
    my $gunl = $m -> Label (-text=>"Gun Status:") -> pack();
    my $gunl2 = $m -> Label (-textvariable=>\$active) -> pack();    
    my $pointsl = $m -> Label (-text=>"Points:") -> pack ();
    my $pointl = $m -> Label (-textvariable=>\$fincount) -> pack();
    my $helpbutt = $m -> Button (-text=>"Help", -command=>\&help) -> pack (-fill=>'x');
    my $newbutt = $m -> Button (-text=>"New Game", -command=>\&newgame) -> pack (-fill=>'x');  
    makeenemies ();        
    $enemiesi = $m -> repeat (100, \&moveenemies); 
    $player -> {'draw'}(); 


    
    MainLoop; 
    
    } 

sub youwin { 
    $m -> Dialog (-text=>"You Win!", -title=>"You Win") -> Show();
    
    } 
sub help { 
    $m -> Dialog (-text=>"Use 'a' and 'w' and 'd' and 's' to move.\nUse 'e' to shoot.\n\nThe object of the game is to move your shot over (to exactly where they are) all of enemy squares to change their color to putple. The secondary object is the avoid being in the exact same spot as an enemy.\n\nGood Luck! ") -> Show();
    } 
    
sub makeenemies { 
    my $e1 = 460;
    my $e2 = 465;
    my $e3 = 470;
    my $e4 = 475;            
    foreach (0 .. 60) { 
        $c -> createRectangle ($e1, $e2, $e3, $e4, -tags=>"$_", -outline=>'darkgreen');
        $e1 -= 7;         
        $e2 -= 7; 
        $e3 -= 7; 
        $e4 -= 7;                         
        } 
    }

sub moveenemies {
    my @coords; 
    my @ycoords; 
    my @ecoords; 
    foreach (0 .. 61) { 
        if ($c -> itemcget ($_, "-state") eq "disabled") { 
            next; 
            } 
        my $rnd1 = int rand (2) + 1; 
        my $rnd2 = int rand (2) + 1; 
        my $x;
        my $y; 
        if ($rnd1 == 1) { 
            $x = 1; 
            }
       if ($rnd1 == 2) { 
            $x = -1; 
            }        
        if ($rnd2 == 1) { 
            $y = 1; 
            }
       if ($rnd2 == 2) { 
            $y = -1; 
            }     

        @coords = $c -> coords ($_); 
        if ($coords[0] < 5) { 
            $x = 1; 
            } 
        if ($coords[1] < 5) { 
            $y = 1;
            } 
        if ($coords[2] > 495) { 
            $x = -1;
            } 
        if ($coords[3] > 495) { 
            $y = -1;
            } 
        foreach my $d (0 .. 1) { 
            @ycoords = $c -> coords ('p');
            @ecoords = $c -> coords ($_);        
            if ($ycoords[0] == $ecoords[0] and $ycoords[1] == $ecoords[1] and $ycoords[2] == $ecoords[2] and $ycoords[3] == $ecoords[3]) { 
                gameover();
                } 
            $c -> move ($_, $x, $y);
            }

        }  

      
        
    }  
    
sub newgame { 
    $m -> destroy ();
    $player = initplayer ();
    init ();

    } 

    
sub gameover { 
    $enemiesi -> cancel; 
    $m -> Dialog (-text=>'Game Over!', -title=>'Game Over') -> Show();
    } 

    
sub initplayer { 
    my $p = { 
        'c1' => '5', 
        'c2' => '10',         
        'c3' => '15',         
        'c4' => '20',         
        'shields' => 10,
        'lives' => 5,
        'weapon' => 'basic',
        'draw' => \&drawplayer
        };  
    bless $p;
    return $p;     
    } 
sub drawplayer { 
    $c -> createRectangle ($player->{'c1'}, $player->{'c2'}, $player->{'c3'},$player->{'c4'}, -tags=>'p', -fill=>'black');

    } 
sub playerleft { 
    $lastkey = 'a';
    my @coords = $c -> coords ('p'); 
    if ($coords[0] == 5) { 
        return; 
        }
    $c -> move ('p', -1, 0);
    $player ->{'c1'} -= 1;               
    $player ->{'c3'} -= 1;    
    } 
sub playerright { 
    $lastkey = 'd';
    my @coords = $c -> coords ('p'); 
    if ($coords[2] == 495) { 
        return; 
        }
    $c -> move ('p', 1, 0);
    $player->{'c1'} += 1; 
    $player->{'c3'} += 1;             
    } 
sub playerup { 
    $lastkey = 'w';
    my @coords = $c -> coords ('p'); 
    if ($coords[1] == 5) { 
        return; 
        }
    $c -> move ('p', 0, -1);
    $player ->{'c2'} -= 1;
    $player ->{'c4'} -= 1; 
    
    } 

sub playerdown { 
    $lastkey = 's'; 
    my @coords = $c -> coords ('p'); 
    if ($coords[3] == 495) { 
        return; 
        }
    $c -> move ('p', 0, 1);
    $player ->{'c2'} += 1;
    $player ->{'c4'} += 1; 
    } 

sub fire {       
    $shotcount += 1; 
    my @coords = $c -> coords ('p');       
    my $shot = $c -> createRectangle ($coords[0], $coords[1], $coords[2], $coords[3], -tags=>"s$shotcount", -fill=>'orange'); 
    $firei = $m -> repeat (2, sub {doshot($shot, $lastkey)});  
    } 

    
sub doshot {                                                
    my $shot = shift; 
    my @coords; 
    $c -> move ($shot, 1,0) if $lastkey eq 'd';
    $c -> move ($shot, -1,0) if $lastkey eq 'a';    
    $c -> move ($shot, 0,1) if $lastkey eq 's';    
    $c -> move ($shot, 0,-1) if $lastkey eq 'w';        
                                     
    my @ecoords; 
    @coords = $c -> coords ($shot);            
    foreach (0 .. 61) { 

        @ecoords = $c -> coords ($_);
        if ($coords[0] == $ecoords[0] and $coords[1] == $ecoords[1] and $coords[2] == $ecoords[2] and $coords[3] == $ecoords[3] and $c -> itemcget ($_, "-state") ne "disabled") { 
            $c -> itemconfigure ($_, -state=>'disabled', -disabledoutline=>'purple');                      $fincount += 1;
            if ($fincount == 61) {
                youwin ();
                } 
            } 
        }     
    if ($j > 3000) { 
        $c -> delete ($shot); 
        $j = 0; 

        $m -> bind ('<e>', \&fire) if $j < 3000; 
        $firei -> cancel ();
        $active = "Available";
        } 
    $m -> bind ('<e>', '') if $j > 0 and $j < 3000; 
    $active = "In Use" if $j > 0 and $j < 3000; ;    
    $j += 1; 
    
    return;
    }
                                    
    
     
