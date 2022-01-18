"
    Abstract environment for an infinite state
"
abstract type AbstractInfEnv <: Cache end;

function leftenv(envs::AbstractInfEnv,pos::Int,state)
    check_recalculate!(envs,state);
    envs.lw[:,pos]
end

function rightenv(envs::AbstractInfEnv,pos::Int,state)
    check_recalculate!(envs,state);
    envs.rw[:,pos]
end

leftenv(envs::AbstractInfEnv,row::Int,col::Int,state) = leftenv(envs,col,state)[row]
rightenv(envs::AbstractInfEnv,row::Int,col::Int,state) = rightenv(envs,col,state)[row]

leftenv(envs,pos::CartesianIndex,state) = leftenv(envs,Tuple(pos)...,state)
rightenv(envs,pos::CartesianIndex,state) = rightenv(envs,Tuple(pos)...,state)

function check_recalculate!(envs,state::InfiniteMPS)
    if !(envs.dependency === state)
        #acquire the lock
        lock(envs) do
            if !(envs.dependency === state)
                recalculate!(envs,state);
            end
        end
    end

    return envs;
end
function check_recalculate!(envs,state::MPSMultiline)
    if !(reduce(&,map(x->x[1]===x[2],zip(envs.dependency,state)),init=true))
        #acquire the lock
        lock(envs) do
            if !(reduce(&,map(x->x[1]===x[2],zip(envs.dependency,state)),init=true))
                recalculate!(envs,state);
            end
        end
    end

    return envs;
end

Base.lock(fun::Function,env::AbstractInfEnv) = lock(fun,env.lock)
Base.lock(env::AbstractInfEnv) = lock(env.lock);
Base.unlock(env::AbstractInfEnv) = unlock(env.lock);
