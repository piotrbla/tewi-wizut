function [ swarm, iterNum, best_l_op,best_zysk, best_Calmar ] = PSO( options,C,pocz,kon,spread)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

swarm = initSwarm(options);
iterNum = 0;
timeOutCounter = 0;

best_l_op = [];
best_zysk = [];
SL= 8*spread:spread:48*spread;
pip = spread/2;
BUF = 2*pip:pip:20*pip;
best_Calmar=0;

%main loop
while (iterNum < options.max_iter_num) && timeOutCounter < (options.best_position_timeout)
    disp([num2str(iterNum*100/options.max_iter_num) ' proc']);
    changed = 0;
    for c=1:length(swarm.particles)
        %rP = unifrnd(0,1,[1 size(options.data_limits,1)])';
        %rS = unifrnd(0,1,[1 size(options.data_limits,1)])';
        
        rP = rand(1, size(options.data_limits,1))';
        rS = rand(1, size(options.data_limits,1))';
        
        swarm.particles(c).velocity = swarm.omega .* swarm.particles(c).velocity +...
            swarm.phi_particle .* rP .* (swarm.particles(c).best_position - swarm.particles(c).position) +...
            swarm.phi_swarm .* rS .* (swarm.best_position - swarm.particles(c).position);
        swarm.particles(c).position = swarm.particles(c).position + ...
            swarm.particles(c).velocity;
        
        %insert bounds-control here
        for i = 1:size(options.data_limits,1)
            tmp = swarm.particles(c).position(i);
            test = tmp < options.data_limits(i,1) || tmp > options.data_limits(i,2);
            if(test)
                min = options.data_limits(i,1);
                max = options.data_limits(i,2);
                pos = min + (max-min).*rand(1,1);
                swarm.particles(c).position(i) = pos;
            end
        end
        swarm.particles(c).position([1,2,3,6]) =...
            round(swarm.particles(c).position([1,2,3,6]));
        swarm.particles(c).position([5]) = SL([round(rand(1,1)*40+ones(1,1))]);
        swarm.particles(c).position([4]) = BUF([round(rand(1,1)*18+ones(1,1))]);
        temp_p = swarm.particles(c).position;
        [ zysk, Calmar, l_open] = ROCa( C, pocz, kon, spread,...
    temp_p(1), temp_p(2), temp_p(3), temp_p(4), temp_p(5), temp_p(6));
        
        if(Calmar > swarm.particles(c).best_position_value)
            swarm.particles(c).best_position = swarm.particles(c).position;
            swarm.particles(c).best_position_value = Calmar;
            
            if(Calmar > swarm.best_position_value)
                swarm.best_position = swarm.particles(c).position;
                swarm.previous_best_position_value = swarm.best_position_value;
                swarm.best_position_value = Calmar;
                zysk
                Calmar
                best_Calmar = Calmar;
                best_l_op = l_open;
                best_zysk = zysk;
                changed = 1;
            end
        end
    end
    
    if(~changed)
        timeOutCounter = timeOutCounter + 1;
    end
    
    iterNum=iterNum + 1;
end


end

function [ swarm ] = initSwarm( options )
particles = initParticles(options);

swarm.particles = particles;
swarm.best_position = particles(1).position;
x = swarm.best_position;
swarm.best_position_value = -Inf;
swarm.previous_best_position_value = Inf;
swarm.omega = options.omega;
swarm.phi_swarm = options.phi_swarm;
swarm.phi_particle = options.phi_particle;
end

%%
function [ particles ] = initParticles( options )
numOfDimensions = size(options.data_limits,1);
positions = zeros(numOfDimensions, options.num_of_particles);
velocities = zeros(numOfDimensions, options.num_of_particles);
%Generating random positions and velocities
for i=1:numOfDimensions
    min = options.data_limits(i,1);
    max = options.data_limits(i,2);
    pos = min + (max-min).*rand(1,options.num_of_particles);
    positions(i,:) = pos;
    
    max_velocity = (options.velocity_limits(i,2) - options.velocity_limits(i,1));
    min_velocity = (-1) * max_velocity;
    vel = min_velocity + (max_velocity - min_velocity) .* rand(1, options.num_of_particles);
    velocities(i,:) = vel;
end

%Generating particles
for i = 1:options.num_of_particles
    particles(i).position = positions(:,i);
    particles(i).velocity = velocities(:,i);
    particles(i).best_position = positions(:,i);
    particles(i).best_position_value = -Inf;
end

end
