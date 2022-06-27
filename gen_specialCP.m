function A=gen_specialCP(n)
%generate a specifically structured instance used in Section 4.1
H=[ 0,            ones(1,n-1);
    ones(n-1,1),  eye(n-1)    ];
A=H'*H;
end