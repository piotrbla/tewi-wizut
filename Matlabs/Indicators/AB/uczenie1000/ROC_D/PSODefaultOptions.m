function [ options ] = PSODefaultOptions(spread)
    pip = spread/2;
    field1 = 'omega' ; value1 = 0.75;
    field2 = 'phi_swarm' ; value2 = 0.65;
    field3 = 'phi_particle' ; value3 = 0.55;
    field4 = 'data_limits' ; value4 = [8 20;
        -500 500;
        6 20;
        -20*pip -2*pip;
        8*spread 48*spread;
        16 240];
    field5 = 'num_of_particles' ; value5 = 150;%200;
    field6 = 'velocity_limits' ; value6 = [0.1 0.9; 0.1 0.9;0.1 0.9;0.1 0.9;0.1 0.9;0.1 0.9];
    field8 = 'max_iter_num'; value8 = 40;%65;
    field9 = 'best_position_timeout'; value9 = Inf;

    options = struct(field1, value1, field2, value2, field3, ...
        value3, field4, value4, field5, value5, field6, value6,...
        field8, value8, field9, value9); 
end