import SwiftUI
import UIKit

@MainActor
func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

@MainActor
func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}

struct DashboardView: View {

    @StateObject var reflectionManager = ReflectionManager.shared
    @StateObject var milestoneManager = MilestoneManager.shared
    @StateObject var workoutManager = WorkoutManager.shared

    @State var showTextReflection = false
    @State var showVoiceReflection = false
    @State var showMilestoneSheet = false
    @State var showActionMenu = false
    
    @State var showAddWorkout = false
    @State var showWorkoutLog = false
    @State var showWeeklySummary = false
    
    @State var readiness: Double = 0.0
    
    @State var animatedCurrentStreak: Int = 0
    @State var animatedLongestStreak: Int = 0
    @State var animatedThisWeek: Int = 0
    @State var selectedDayIndex: Int? = nil
    
    @State var insights: PerformanceInsights?
    @State var simulatedStats: SimulatedAthleteStats?
    
    @State var showAchievementUnlock = false
    @State var unlockedMilestone: Milestone?
    
    @State var userName: String = ""
    
    @AppStorage("sparc_show_fab_hint") var showFabHint: Bool = true
    
    @State var showMotivation = false
    @State var tooltipMessage: String? = nil
    @State var showTooltip = false

    var body: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            mainScrollView
            
            if showMotivation {
                DailyMotivationView(isPresented: $showMotivation).zIndex(20)
            }
            
            if showTooltip, let message = tooltipMessage {
                tooltipOverlay(message: message)
            }
            
            if showAchievementUnlock {
                AchievementUnlockView(milestone: unlockedMilestone)
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(10)
            }
            
            floatingActionButton
        }
        .dashboardSheets(
            showText: $showTextReflection,
            showVoice: $showVoiceReflection,
            showMilestone: $showMilestoneSheet,
            showWorkout: $showAddWorkout,
            showLog: $showWorkoutLog,
            showSummary: $showWeeklySummary,
            reflectionManager: reflectionManager,
            milestoneManager: milestoneManager,
            workoutManager: workoutManager,
            insights: insights
        )
        .dashboardLifecycle(
            reflectionManager: reflectionManager,
            workoutManager: workoutManager,
            milestoneManager: milestoneManager,
            unlockedMilestone: $unlockedMilestone,
            showUnlock: $showAchievementUnlock,
            updateAction: generateAllData
        )
        .dashboardToolbar(showSummary: $showWeeklySummary)
    }
    
    private var mainScrollView: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                performanceSection
                analyticsSection
                activitySection
                weeklyChartSection
                insightsSection
                historySection
                HealthLibraryView().padding(.top, 20)
                Spacer(minLength: 100)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - SECTIONS
extension DashboardView {
    
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Ready to rise,").font(.system(size: 22, weight: .medium)).foregroundColor(.gray)
                Text(userName.isEmpty ? "Athlete" : userName).font(.system(size: 28, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var performanceSection: some View {
        ZStack {
            PerformanceRing(progress: readiness)
                .shadow(color: .sparcCyan.opacity(readiness > 0.8 ? 0.8 : 0.5), radius: readiness > 0.8 ? 30 : 20)
                .scaleEffect(readiness > 0.8 ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: readiness)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button { showWorkoutLog = true } label: {
                        Image(systemName: "list.bullet.clipboard").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                            .frame(width: 44, height: 44).background(Circle().fill(Color.sparcViolet))
                            .shadow(color: .sparcViolet.opacity(0.8), radius: 10, x: 0, y: 4)
                    }
                    .accessibilityLabel("Workout History")
                    .accessibilityHint("Shows a log of all your recorded workouts")
                    .padding(.trailing, 40).padding(.bottom, -10)
                }
            }
        }
        .frame(height: 220)
    }
    
    var analyticsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Performance Analytics").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
            }
            HStack(spacing: 16) {
                analyticsCard(title: "Current Streak", value: "\(animatedCurrentStreak)", icon: "flame.fill", tooltip: "Your consecutive days of activity and reflection.")
                analyticsCard(title: "Longest", value: "\(animatedLongestStreak)", icon: "trophy.fill", tooltip: "Your historical record for the longest streak.")
                analyticsCard(title: "This Week", value: "\(animatedThisWeek)", icon: "calendar", tooltip: "Total activities completed this week.")
            }
        }
        .padding(.horizontal)
    }
    
    var activitySection: some View {
        Group {
            if let stats = simulatedStats {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Activity").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                    HStack(spacing: 16) {
                        activityCard(title: "Steps", value: "\(stats.steps)", icon: "figure.walk")
                        activityCard(title: "Active kcal", value: "\(stats.activeCalories)", icon: "flame")
                    }
                    HStack(spacing: 16) {
                        activityCard(title: "Intensity", value: "\(stats.trainingIntensity)", icon: "bolt.fill")
                        activityCard(title: "Recovery", value: "\(stats.recoveryScore)", icon: "heart.fill")
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("This Week").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            HStack(alignment: .bottom, spacing: 16) {
                let counts = reflectionManager.weeklyReflectionCounts()
                let days = ["M","T","W","T","F","S","S"]
                ForEach(0..<7, id: \.self) { index in
                    let value = counts[index]
                    let isSelected = selectedDayIndex == index
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: isSelected ? [.sparcViolet, .sparcCyan] : [.sparcCyan.opacity(0.5), .sparcViolet.opacity(0.5)], startPoint: .bottom, endPoint: .top))
                            .frame(width: 24, height: CGFloat(max(value, 1)) * 28)
                        Text(days[index]).foregroundColor(isSelected ? .sparcCyan : .gray).font(.system(size: 12))
                    }
                    .onTapGesture { selectedDayIndex = selectedDayIndex == index ? nil : index }
                }
            }
        }
        .padding().background(RoundedRectangle(cornerRadius: 22).fill(Color.sparcCard)).padding(.horizontal)
    }
    
    var insightsSection: some View {
        Group {
            if let insights = insights {
                TabView {
                    insightCard(title: "Growth Insight", text: insights.insightText, momentum: insights.momentumText, scoreLabel: "Overall Score: \(insights.score)", tier: insights.tier)
                    resilienceCard(index: insights.resilienceIndex)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 180)
            }
        }
    }
    
    var historySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let latest = reflectionManager.reflections.first {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latest Reflection").font(.system(size: 16, weight: .medium)).foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(latest.mood).font(.caption).bold().padding(.horizontal, 8).padding(.vertical, 4).background(Color.white.opacity(0.1)).cornerRadius(8)
                            Spacer()
                            Text(latest.date.formatted(date: .abbreviated, time: .omitted)).font(.caption).foregroundColor(.gray)
                        }
                        Text(latest.text).foregroundColor(.white)
                    }
                    .padding().background(Color.sparcCard).cornerRadius(16)
                }
            }
            if let latest = milestoneManager.milestones.first {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Latest Milestone").font(.system(size: 16, weight: .medium)).foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(latest.title).foregroundColor(.white)
                        Text(latest.description).foregroundColor(.gray)
                    }
                    .padding().background(Color.sparcCard).cornerRadius(16)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - COMPONENTS
extension DashboardView {
    
    private func insightCard(title: String, text: String, momentum: String, scoreLabel: String, tier: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Text(momentum).font(.caption).bold().padding(.horizontal, 8).padding(.vertical, 4).background(Color.sparcViolet.opacity(0.2)).cornerRadius(8).foregroundColor(.sparcViolet)
            }
            Text(text).foregroundColor(.white.opacity(0.9))
            HStack {
                Text(scoreLabel).foregroundColor(.sparcCyan)
                Spacer()
                Text(tier).foregroundColor(.sparcViolet)
            }
        }
        .padding().background(Color.sparcCard).cornerRadius(22).padding(.horizontal)
    }
    
    private func resilienceCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mental Resilience").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Spacer()
                Image(systemName: "brain.head.profile").foregroundColor(.sparcCyan).font(.title2)
            }
            Text("Consistency creates a solid mental foundation.").foregroundColor(.white.opacity(0.9))
            HStack {
                Text("Resilience Index: \(index)/100").foregroundColor(.sparcCyan)
                Spacer()
                Text("Strong").foregroundColor(.white)
            }
        }
        .padding().background(Color.sparcCard).cornerRadius(22).padding(.horizontal)
    }
    
    private func tooltipOverlay(message: String) -> some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { showTooltip = false }
            VStack {
                Text(message).font(.system(size: 14)).foregroundColor(.white).padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.sparcCard)).shadow(radius: 10)
            }
            .padding(40)
        }
        .zIndex(25)
    }
    
    private var floatingActionButton: some View {
        ZStack {
            if showActionMenu {
                Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { withAnimation(.spring()) { showActionMenu = false } }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        if showFabHint {
                            Text("Tap here to log activity").font(.system(size: 12, weight: .bold)).padding(10).background(Color.sparcViolet).cornerRadius(10).onTapGesture { showFabHint = false }
                        }
                        if showActionMenu {
                            actionButtons
                        }
                        mainFab
                    }.padding()
                }
            }
        }
    }
    
    private var actionButtons: some View {
        Group {
            ActionButton(icon: "figure.run", label: "Log Workout").onTapGesture { showAddWorkout = true; showActionMenu = false }
            ActionButton(icon: "mic.fill", label: "Voice Reflection").onTapGesture { showVoiceReflection = true; showActionMenu = false }
            ActionButton(icon: "pencil", label: "Text Reflection").onTapGesture { showTextReflection = true; showActionMenu = false }
            ActionButton(icon: "flag.fill", label: "Add Milestone").onTapGesture { showMilestoneSheet = true; showActionMenu = false }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var mainFab: some View {
        Button {
            triggerHapticFeedback(.rigid)
            withAnimation(.spring()) { showActionMenu.toggle(); showFabHint = false }
        } label: {
            Circle().fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 65, height: 65).overlay(Image(systemName: showActionMenu ? "xmark" : "bolt.fill").foregroundColor(.black).font(.system(size: 22)))
                .shadow(color: .sparcCyan.opacity(0.7), radius: 12)
        }
        .accessibilityLabel(showActionMenu ? "Close menu" : "Add activity")
        .accessibilityHint("Opens a menu to log workouts, reflections, or milestones")
    }
}

// MARK: - HELPERS
extension DashboardView {
    
    func analyticsCard(title: String, value: String, icon: String, tooltip: String? = nil) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(.sparcCyan)
                if tooltip != nil { Spacer(); Image(systemName: "info.circle").font(.caption2).foregroundColor(.gray.opacity(0.6)) }
            }
            Text(value).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding().background(Color.sparcCard).cornerRadius(20)
        .onTapGesture { if let t = tooltip { tooltipMessage = t; showTooltip = true } }
    }
    
    func activityCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon).foregroundColor(.sparcCyan)
                Spacer()
            }
            Text(value).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding().background(Color.sparcCard).cornerRadius(20)
    }
    
    func generateAllData() {
        let newInsights = PerformanceEngine.generateInsights(reflections: reflectionManager.reflections, workouts: workoutManager.workouts, milestonesCount: milestoneManager.milestones.count, currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak))
        let newStats = AthleteSimulationEngine.generateStats(reflectionsCount: reflectionManager.reflections.count, workouts: workoutManager.workouts, currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak), milestones: milestoneManager.milestones.count)
        
        withAnimation {
            animatedCurrentStreak = reflectionManager.currentStreak
            animatedLongestStreak = reflectionManager.longestStreak
            animatedThisWeek = reflectionManager.reflectionsThisWeek
            insights = newInsights
            simulatedStats = newStats
            readiness = newStats.readinessScore
            if let data = UserDefaults.standard.data(forKey: "sparc_profile"), let profile = try? JSONDecoder().decode(AthleteProfile.self, from: data) {
                userName = profile.name
            }
        }
        checkDailyMotivation()
    }
    
    func checkDailyMotivation() {
        let lastShown = UserDefaults.standard.object(forKey: "sparc_last_motivation_date") as? Date ?? .distantPast
        if !Calendar.current.isDateInToday(lastShown) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showMotivation = true
                UserDefaults.standard.set(Date(), forKey: "sparc_last_motivation_date")
            }
        }
    }
}

// MARK: - GRANULAR MODIFIERS
extension View {
    
    func dashboardSheets(showText: Binding<Bool>, showVoice: Binding<Bool>, showMilestone: Binding<Bool>, showWorkout: Binding<Bool>, showLog: Binding<Bool>, showSummary: Binding<Bool>, reflectionManager: ReflectionManager, milestoneManager: MilestoneManager, workoutManager: WorkoutManager, insights: PerformanceInsights?) -> some View {
        self
            .sheet(isPresented: showText) { TextReflectionView(manager: reflectionManager) }
            .sheet(isPresented: showVoice) { VoiceReflectionView() }
            .sheet(isPresented: showMilestone) { AddMilestoneView(manager: milestoneManager) }
            .sheet(isPresented: showWorkout) { AddWorkoutView(manager: workoutManager) }
            .sheet(isPresented: showLog) { WorkoutLogView(manager: workoutManager) }
            .sheet(isPresented: showSummary) {
                if let insights = insights {
                    WeeklySummaryView(insights: insights, weeklyVolumeThisWeek: workoutManager.weeklyVolumeThisWeek, reflectionStreak: reflectionManager.currentStreak)
                }
            }
    }
    
    func dashboardLifecycle(reflectionManager: ReflectionManager, workoutManager: WorkoutManager, milestoneManager: MilestoneManager, unlockedMilestone: Binding<Milestone?>, showUnlock: Binding<Bool>, updateAction: @escaping () -> Void) -> some View {
        self
            .onAppear { updateAction() }
            .onChange(of: reflectionManager.reflections.count) { _ in updateAction() }
            .onChange(of: workoutManager.workouts.count) { _ in updateAction() }
            .onChange(of: milestoneManager.milestones.count) { _ in
                guard let latest = milestoneManager.milestones.first else { return }
                unlockedMilestone.wrappedValue = latest
                withAnimation { showUnlock.wrappedValue = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { withAnimation { showUnlock.wrappedValue = false } }
            }
    }
    
    func dashboardToolbar(showSummary: Binding<Bool>) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showSummary.wrappedValue = true } label: { Image(systemName: "chart.bar.doc.horizontal").foregroundColor(.sparcViolet) }
                        .accessibilityLabel("Weekly Summary")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle.fill").font(.system(size: 22))
                            .foregroundStyle(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .accessibilityLabel("Your Profile")
                    }
                }
            }
    }
}
