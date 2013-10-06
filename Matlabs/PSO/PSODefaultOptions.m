function [ options ] = PSODefaultOptions(spread)
    pip = spread/2;
    field1 = 'omega' ; value1 = 0.85;
    field2 = 'phi_swarm' ; value2 = 0.65;
    field3 = 'phi_particle' ; value3 = 0.45;
    field4 = 'data_limits' ; value4 = [-20*pip -pip; 
        17 24;
        1 7;
        4 50;
        8*spread 48*spread;
        8*spread 48*spread;
        100 500;
        4 9;
        3 18;
        5*spread 10*spread;
        3*spread 15*spread];
    field5 = 'num_of_particles' ; value5 = 250;
    field6 = 'velocity_limits' ; value6 = [0.1 0.9; 0.1 0.9;0.1 0.9;...
        0.1 0.9;0.1 0.9;0.1 0.9;0.1 0.9;0.1 0.9;0.1 0.9;0.1 ...
        0.9;0.1 0.9];
    field8 = 'max_iter_num'; value8 = 110;
    field9 = 'best_position_timeout'; value9 = Inf;

    options = struct(field1, value1, field2, value2, field3, ...
        value3, field4, value4, field5, value5, field6, value6,...
        field8, value8, field9, value9);
end