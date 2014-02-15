function [ options ] = PSODefaultOptions(spread, P)
    field1 = 'omega' ; value1 = 0.85;
    field2 = 'phi_swarm' ; value2 = 0.75;
    field3 = 'phi_particle' ; value3 = 0.45;
    field4 = 'data_limits' ; value4 = [P(1,1) P(1,2); 
        P(2,1) P(2,2);
        P(3,1) P(3,2);
        P(4,1) P(4,2);
        P(5,1) P(5,2);
        P(6,1) P(6,2);
        P(6,1) P(6,2);];
    field5 = 'num_of_particles' ; value5 = 80;
    field6 = 'velocity_limits' ; value6 = [0.1 0.9; 0.1 0.9;0.1 0.9;...
        0.1 0.9; 0.1 0.9; 0.1 0.9; 0.1 0.9];
    field8 = 'max_iter_num'; value8 = 50;
    field9 = 'best_position_timeout'; value9 = Inf;

    options = struct(field1, value1, field2, value2, field3, ...
        value3, field4, value4, field5, value5, field6, value6,...
        field8, value8, field9, value9);
end