function dynamic_alpha_curve_tester
% dynamic_alpha_curve_tester
% Tests shapes of alpha curves

tauSet = [20, 40, 100, 200];
t = 0:1:2000;

figure('Color','w');
for(q=1:4)
    tau = tauSet(q);
    y = (t/tau).*exp(1-(t/tau));
    y = y/max(y);

    tmax = find(y==1);
    t90 = find(y>0.1,1,'last');

    subplot(2,2,q);
    hold on;
    plot(t,y);
    plot(t90,y(t90),'r.');
    text(t90+100,y(t90),num2str(round(t90)),'Color','red');
    hold off;
    title(['tau = ' num2str(tau)]);
end

end