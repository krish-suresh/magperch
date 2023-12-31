# Enable warm-starting
function mpc_JuMP!(optimizer, params, X, U, A, B, f; warm_start=true)
    Nh = params.N
    nx = params.nx
    nu = params.nu
    # α_max = params.c_cone[3]
    NN = Nh*nx + (Nh-1)*nu
    x0 = 1*X[1]
    
    inds = reshape(1:(nx+nu)*Nh,nx+nu,Nh)  
    xinds = [z[1:nx] for z in eachcol(inds)]
    uinds = [z[nx+1:end] for z in eachcol(inds)][1:Nh-1]    
    
    model = Model(optimizer)
    
    @variable(model, z[1:NN])  # z is all decision variables (X U)
    if warm_start
        z_ws = zeros(NN,1)
        for j = 1:Nh-1
            z_ws[xinds[j]] .= X[j]
            z_ws[uinds[j]] .= U[j]
        end
        z_ws[xinds[Nh]] .= X[Nh]
        set_start_value.(z, z_ws)
    end
    
    P = zeros(NN, NN)
    q = zeros(NN, 1) 
    # Cost function   
    for j = 1:Nh-1
        P[(j-1)*(nx+nu).+(1:nx),(j-1)*(nx+nu).+(1:nx)], q[(j-1)*(nx+nu).+(1:nx)], 
        P[(j-1)*(nx+nu)+nx.+(1:nu),(j-1)*(nx+nu)+nx.+(1:nu)], q[(j-1)*(nx+nu)+nx.+(1:nu)] = stage_cost_expansion(params, j)
    end    
    P[end-nx+1:end,end-nx+1:end], q[end-nx+1:end] = term_cost_expansion(params)
    @objective(model, Min, 0.5*dot(z,P,z) + dot(q,z))
  
    # Dynamics Constraints
    for k = 1:Nh-1
        @constraint(model, A*z[xinds[k]] .+ B*z[uinds[k]] .+ f .== z[xinds[k+1]])
    end
    
    # Initial condition 
    @constraint(model, z[xinds[1]] .== x0)
    
    # Thrust angle constraint
    # if params.ncu_cone > 0 
    #   for k = 1:Nh-1
    #       u1,u2,u3 = z[uinds[k]]
    #       @constraint(model, [α_max * u3, u1, u2] in JuMP.SecondOrderCone())
    #   end
    # end
    
    # State Constraints
    if params.ncx > 0 
      for k = 1:Nh
        @constraint(model, z[xinds[k]] .<= params.x_max)
        @constraint(model, z[xinds[k]] .>= params.x_min)
      end  
    end
  
    # Input Constraints
    if params.ncu > 0 
      for k = 1:Nh-1
        @constraint(model, z[uinds[k]] .<= params.u_max)
        @constraint(model, z[uinds[k]] .>= params.u_min)
      end  
    end
  
    # Goal constraint
    if params.ncg > 0 
      @constraint(model, z[xinds[Nh]] .== params.Xref[Nh])
    end    
  
    @time optimize!(model)   
    # termination_status(model) == INFEASIBLE && print("Other solver says INFEASIBLE\n")
    for j = 1:Nh-1
        X[j] .= value.(z[xinds[j]]) 
        U[j] .= value.(z[uinds[j]]) 
    end    
    X[Nh] .= value.(z[xinds[Nh]])
    # display(MOI.get(model, MOI.SolveTimeSec()))
    return U[1]
end

# Enable warm-starting
function trajopt_JuMP!(optimizer, params, X, U, A, B, f; warm_start=true)
    Nh = params.N
    nx = params.nx
    nu = params.nu
    # α_max = params.c_cone[3]
    NN = Nh*nx + (Nh-1)*nu
    x0 = 1*X[1]
    
    inds = reshape(1:(nx+nu)*Nh,nx+nu,Nh)  
    xinds = [z[1:nx] for z in eachcol(inds)]
    uinds = [z[nx+1:end] for z in eachcol(inds)][1:Nh-1]    
    
    model = Model(optimizer)
    
    @variable(model, z[1:NN])  # z is all decision variables (X U)
    if warm_start
        z_ws = zeros(NN,1)
        for j = 1:Nh-1
            z_ws[xinds[j]] .= X[j]
            z_ws[uinds[j]] .= U[j]
        end
        z_ws[xinds[Nh]] .= X[Nh]
        set_start_value.(z, z_ws)
    end
    
    P = zeros(NN, NN)
    q = zeros(NN, 1) 
    # Cost function   
    for j = 1:Nh-1
        P[(j-1)*(nx+nu).+(1:nx),(j-1)*(nx+nu).+(1:nx)], q[(j-1)*(nx+nu).+(1:nx)], 
        P[(j-1)*(nx+nu)+nx.+(1:nu),(j-1)*(nx+nu)+nx.+(1:nu)], q[(j-1)*(nx+nu)+nx.+(1:nu)] = stage_cost_expansion(params, j)
    end    
    P[end-nx+1:end,end-nx+1:end], q[end-nx+1:end] = term_cost_expansion(params)
    @objective(model, Min, 0.5*dot(z,P,z) + dot(q,z))
  
    # Dynamics Constraints
    for k = 1:Nh-1
        @constraint(model, A*z[xinds[k]] .+ B*z[uinds[k]] .+ f .== z[xinds[k+1]])
    end
    
    # Initial condition 
    @constraint(model, z[xinds[1]] .== x0)
    
    # Thrust angle constraint
    # if params.ncu_cone > 0 
    #   for k = 1:Nh-1
    #       u1,u2,u3 = z[uinds[k]]
    #       @constraint(model, [α_max * u3, u1, u2] in JuMP.SecondOrderCone())
    #   end
    # end
    
    # State Constraints
    if params.ncx > 0 
      for k = 1:Nh
        @constraint(model, z[xinds[k]] .<= params.x_max)
        @constraint(model, z[xinds[k]] .>= params.x_min)
      end  
    end
  
    # Input Constraints
    if params.ncu > 0 
      for k = 1:Nh-1
        @constraint(model, z[uinds[k]] .<= params.u_max)
        @constraint(model, z[uinds[k]] .>= params.u_min)
      end  
    end
  
    # Goal constraint
    if params.ncg > 0 
        @constraint(model, z[xinds[Nh]] .== params.Xref[Nh])
    end    
  
    optimize!(model)   
    termination_status(model) == INFEASIBLE && print("Other solver says INFEASIBLE\n")
    for j = 1:Nh-1
        X[j] .= value.(z[xinds[j]]) 
        U[j] .= value.(z[uinds[j]]) 
    end    
    X[Nh] .= value.(z[xinds[Nh]])
    # display(MOI.get(model, MOI.SolveTimeSec()))
    return X
  end