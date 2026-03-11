import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject var manager = ProfileManager.shared
    @StateObject var settings = SettingsManager.shared
    @StateObject var workoutManager = WorkoutManager.shared
    @StateObject var reflectionManager = ReflectionManager.shared
    @StateObject var milestoneManager = MilestoneManager.shared
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var profileImage: Image?
    
    @State var isEditing = false
    @State var showAddAchievement = false
    
    @State var layoutMode: LayoutMode = .list
    @State var showMediaViewer = false
    @State var selectedMediaIndex = 0
    
    @State var appearIndex = 0
    
    @State var achievementToDelete: Achievement?
    @State var showDeleteConfirmation = false
    
    @State var showShareSheet = false
    @State var shareImage: UIImage? = nil
    @State var shareURL: URL? = nil
    @State var showResetConfirmation = false
    @State var showEditOnboarding = false
    
    enum LayoutMode {
        case list, grid, timeline
    }
    
    var archetype: String {
        var result = "Driven Athlete ⚡️"
        if let data = UserDefaults.standard.data(forKey: "sparc_assessment"),
           let assessment = try? JSONDecoder().decode(AthleteAssessment.self, from: data) {
            let training = assessment.trainingDays
            let mental = assessment.mentalResilience
            
            if training == "Every Day" && mental.contains("Thrive") {
                result = "Elite Competitor 🏆"
            } else if training.contains("5-6") {
                result = "The Competitor 🥇"
            } else if training.contains("3-4") {
                result = "The Builder 🚀"
            } else {
                result = "The Strategist 🧠"
            }
        }
        return result
    }
    
    var body: some View {
        mainContent
            .profileToolbar(isEditing: $isEditing, saveAction: manager.save)
            .profileSheets(showAdd: $showAddAchievement, showShare: $showShareSheet, showEditOnboarding: $showEditOnboarding, manager: manager, shareImage: shareImage, shareURL: shareURL)
            .profileOverlays(showMedia: $showMediaViewer, achievements: manager.profile.achievements, index: selectedMediaIndex)
            .profileConfirmations(showDelete: $showDeleteConfirmation, showReset: $showResetConfirmation, achievement: achievementToDelete, deleteAction: {
                if let toDelete = achievementToDelete {
                    withAnimation {
                        manager.profile.achievements.removeAll { $0.id == toDelete.id }
                        manager.save()
                    }
                }
            }, resetAction: resetAllData)
            .profileLifecycle(selectedPhoto: $selectedPhoto, profileImage: $profileImage, achievementCount: manager.profile.achievements.count, appearIndex: $appearIndex)
    }
    
    private var mainContent: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 35) {
                    heroSection
                    portfolioSection
                    aboutSection
                    achievementsSection
                    settingsSection
                    Color.clear.frame(height: 40)
                }
                .padding()
            }
        }
    }
}

// MARK: - HERO
extension ProfileView {
    var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 140, height: 140)
                
                if let profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.black)
                }
            }
            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Edit Photo").foregroundColor(.sparcCyan)
            }
            
            if isEditing {
                TextField("Your Name", text: $manager.profile.name)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            } else {
                Text(manager.profile.name.isEmpty ? "Your Name" : manager.profile.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if isEditing {
                TextField("Sport", text: $manager.profile.sport)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            } else {
                Text(manager.profile.sport.isEmpty ? "Your Sport" : manager.profile.sport)
                    .foregroundColor(.gray)
            }
            
            Text(archetype)
                .font(.caption).bold()
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Color.sparcViolet.opacity(0.2))
                .cornerRadius(12).foregroundColor(.sparcViolet)
        }
    }
}

// MARK: - PORTFOLIO
extension ProfileView {
    var portfolioSection: some View {
        let stats = AthleteSimulationEngine.generateStats(
            reflectionsCount: reflectionManager.reflections.count,
            workouts: workoutManager.workouts,
            currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak),
            milestones: milestoneManager.milestones.count
        )
        
        let insights = PerformanceEngine.generateInsights(
            reflections: reflectionManager.reflections,
            workouts: workoutManager.workouts,
            milestonesCount: milestoneManager.milestones.count,
            currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak)
        )
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Athlete Portfolio").foregroundColor(.gray).font(.system(size: 14, weight: .medium))
                Spacer()
                Button(action: generateShareCard) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Card")
                    }
                    .font(.system(size: 12, weight: .bold)).foregroundColor(.sparcCyan)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.sparcCyan.opacity(0.1)).cornerRadius(8)
                }
            }
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    portfolioStatTile(label: "Workouts", value: "\(workoutManager.workouts.count)", icon: "figure.run")
                    portfolioStatTile(label: "Streak", value: "\(max(reflectionManager.currentStreak, workoutManager.currentStreak))d", icon: "flame.fill")
                    portfolioStatTile(label: "Growth", value: "+12%", icon: "arrow.up.right")
                }
                
                HStack(spacing: 12) {
                    portfolioStatTile(label: "Readiness", value: "\(Int(stats.readinessScore * 100))%", icon: "bolt.fill")
                    portfolioStatTile(label: "Mental Index", value: "\(insights.resilienceIndex)", icon: "brain")
                    portfolioStatTile(label: "Tier", value: insights.tier, icon: "crown")
                }
            }
        }
    }
    
    private func portfolioStatTile(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(.sparcCyan)
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text(label).font(.system(size: 10)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
    }
    
    func generateShareCard() {
        let stats = AthleteSimulationEngine.generateStats(
            reflectionsCount: reflectionManager.reflections.count,
            workouts: workoutManager.workouts,
            currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak),
            milestones: milestoneManager.milestones.count
        )
        let insights = PerformanceEngine.generateInsights(
            reflections: reflectionManager.reflections,
            workouts: workoutManager.workouts,
            milestonesCount: milestoneManager.milestones.count,
            currentStreak: max(reflectionManager.currentStreak, workoutManager.currentStreak)
        )
        let card = PortfolioShareCard(profile: manager.profile, archetype: archetype, stats: stats, insights: insights)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        if let image = renderer.uiImage {
            self.shareImage = image
            self.showShareSheet = true
        }
    }
}

// MARK: - ABOUT
extension ProfileView {
    var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About").foregroundColor(.gray).font(.system(size: 14, weight: .medium))
            if isEditing {
                TextEditor(text: $manager.profile.bio)
                    .scrollContentBackground(.hidden).foregroundColor(.white).padding(12).frame(height: 110)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.sparcCard.opacity(0.9)).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.sparcCyan.opacity(0.25), lineWidth: 1)))
            } else {
                Text(manager.profile.bio.isEmpty ? "Add your journey, discipline and mindset here." : manager.profile.bio)
                    .foregroundColor(.white.opacity(0.85)).lineSpacing(4).padding(16)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.sparcCard.opacity(0.85)))
            }
        }
    }
}

// MARK: - ACHIEVEMENTS
extension ProfileView {
    var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Achievements").foregroundColor(.gray)
                Spacer()
                Button { layoutMode = .list } label: { Image(systemName: "list.bullet").foregroundColor(layoutMode == .list ? .sparcCyan : .gray) }
                Button { layoutMode = .grid } label: { Image(systemName: "square.grid.2x2").foregroundColor(layoutMode == .grid ? .sparcCyan : .gray) }
                Button { layoutMode = .timeline } label: { Image(systemName: "point.topleft.down.curvedto.point.bottomright.up").foregroundColor(layoutMode == .timeline ? .sparcCyan : .gray) }
                if isEditing {
                    Button { showAddAchievement = true } label: { Image(systemName: "plus.circle.fill").foregroundColor(.sparcCyan) }
                }
            }
            Group {
                switch layoutMode {
                case .list: listLayout
                case .grid: gridLayout
                case .timeline: timelineLayout
                }
            }
            .transition(.opacity.combined(with: .scale)).animation(.easeInOut(duration: 0.25), value: layoutMode)
        }
    }
    
    var listLayout: some View {
        VStack(spacing: 18) {
            ForEach(manager.profile.achievements.indices, id: \.self) { index in
                let achievement = manager.profile.achievements[index]
                HStack(spacing: 14) {
                    if let data = achievement.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 110, height: 80).clipped().cornerRadius(14).onTapGesture { openViewer(for: achievement) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(achievement.title).foregroundColor(.white).font(.system(size: 16, weight: .semibold))
                        Text(achievement.year).foregroundColor(.gray).font(.system(size: 13))
                    }
                    Spacer()
                    if isEditing {
                        Button { achievementToDelete = achievement; showDeleteConfirmation = true } label: { Image(systemName: "trash.circle.fill").foregroundColor(.red).font(.system(size: 24)) }
                    }
                }
                .padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.sparcCard).shadow(color: .black.opacity(0.4), radius: 10, y: 6))
                .opacity(appearIndex > index ? 1 : 0).offset(y: appearIndex > index ? 0 : 20).animation(.easeOut(duration: 0.4).delay(Double(index) * 0.05), value: appearIndex)
            }
        }
    }
    
    var gridLayout: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(manager.profile.achievements.indices, id: \.self) { index in
                let achievement = manager.profile.achievements[index]
                VStack(spacing: 0) {
                    if let data = achievement.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage).resizable().scaledToFill().frame(height: 140).frame(maxWidth: .infinity).clipped().onTapGesture { openViewer(for: achievement) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(achievement.title).foregroundColor(.white).font(.system(size: 15, weight: .semibold)).lineLimit(2)
                        Text(achievement.year).foregroundColor(.gray).font(.system(size: 12))
                    }
                    .padding(12).frame(height: 75)
                }
                .frame(height: 215).background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard).shadow(color: .black.opacity(0.3), radius: 8, y: 4))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    if isEditing {
                        Button { achievementToDelete = achievement; showDeleteConfirmation = true } label: { Image(systemName: "trash.circle.fill").foregroundColor(.red).font(.system(size: 24)).background(Circle().fill(Color.black.opacity(0.5))) }
                        .padding(8)
                    }
                }
                .opacity(appearIndex > index ? 1 : 0).offset(y: appearIndex > index ? 0 : 20).animation(.easeOut(duration: 0.4).delay(Double(index) * 0.05), value: appearIndex)
            }
        }
    }
    
    var timelineLayout: some View {
        let grouped = Dictionary(grouping: manager.profile.achievements) { $0.year }.sorted { $0.key > $1.key }
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(grouped, id: \.key) { year, items in
                VStack(alignment: .leading, spacing: 0) {
                    Text(year).font(.system(size: 26, weight: .bold)).foregroundStyle(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .leading, endPoint: .trailing)).padding(.bottom, 24).padding(.leading, 36)
                    ForEach(items) { achievement in
                        TimelineNodeView(achievement: achievement, isEditing: isEditing, deleteAction: { achievementToDelete = achievement; showDeleteConfirmation = true })
                            .padding(.bottom, 16)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - SETTINGS
extension ProfileView {
    var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings").foregroundColor(.gray).font(.system(size: 14, weight: .medium))
            VStack(spacing: 1) {
                settingToggle(title: "Dark Mode", isOn: Binding(get: { settings.themeSelection == 2 }, set: { settings.themeSelection = $0 ? 2 : 1 }), icon: "moon.fill", color: .indigo)
                settingToggle(title: "Daily Motivation", isOn: $settings.motivationEnabled, icon: "quote.bubble.fill", color: .sparcCyan)
                settingToggle(title: "App Notifications", isOn: $settings.notificationsEnabled, icon: "bell.badge.fill", color: .sparcViolet)
                
                Button(action: { showEditOnboarding = true }) {
                    HStack {
                        Image(systemName: "pencil.and.outline")
                        Text("Retake Assessment")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .foregroundColor(.white).padding(16).background(Color.sparcCard)
                }
                
                Button(action: { exportData() }) {
                    HStack { Image(systemName: "square.and.arrow.up"); Text("Export Athlete Data"); Spacer() }
                    .foregroundColor(.white).padding(16).background(Color.sparcCard)
                }
                
                Button(action: { showResetConfirmation = true }) {
                    HStack { Image(systemName: "trash.fill").foregroundColor(.red); Text("Reset All Data").foregroundColor(.red); Spacer() }
                    .padding(16).background(Color.sparcCard)
                }
                
                VStack(alignment: .center, spacing: 4) {
                    Text("SPARC v1.2.0").font(.caption2).foregroundColor(.gray)
                    Text("Scholarship Edition").font(.system(size: 8, weight: .bold)).foregroundColor(.sparcCyan.opacity(0.6))
                }
                .padding(.vertical, 20).frame(maxWidth: .infinity)
            }
            .cornerRadius(18).overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.05), lineWidth: 1))
        }
    }
    
    private func settingToggle(title: String, isOn: Binding<Bool>, icon: String, color: Color) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundColor(color).frame(width: 24)
                Text(title).foregroundColor(.white)
            }
        }
        .padding(16).background(Color.sparcCard)
    }
    
    func resetAllData() {
        let keys = ["sparc_profile", "sparc_reflections", "sparc_workouts", "sparc_milestones", "sparc_assessment", "sparc_onboarding_completed"]
        for key in keys { UserDefaults.standard.removeObject(forKey: key) }
        manager.profile = AthleteProfile()
        manager.save()
        isEditing = false
    }
    
    func exportData() {
        let jsonStr = "SPARC Athlete Data Export - \(manager.profile.name)\nWorkouts: \(workoutManager.workouts.count)\nAchievements: \(manager.profile.achievements.count)\nDate: \(Date().formatted())"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SPARC_Profile.txt")
        try? jsonStr.write(to: url, atomically: true, encoding: .utf8)
        self.shareImage = nil
        self.shareURL = url
        self.showShareSheet = true
    }
}

// MARK: - HELPERS
extension ProfileView {
    func openViewer(for achievement: Achievement) {
        selectedMediaIndex = manager.profile.achievements.firstIndex { $0.id == achievement.id } ?? 0
        showMediaViewer = true
    }
}

// MARK: - GRANULAR MODIFIERS
extension View {
    
    func profileToolbar(isEditing: Binding<Bool>, saveAction: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing.wrappedValue ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.wrappedValue.toggle()
                        saveAction()
                    }
                }
                .foregroundColor(.sparcCyan)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func profileSheets(showAdd: Binding<Bool>, showShare: Binding<Bool>, showEditOnboarding: Binding<Bool>, manager: ProfileManager, shareImage: UIImage?, shareURL: URL?) -> some View {
        self
            .sheet(isPresented: showAdd) { AddAchievementView(manager: manager) }
            .sheet(isPresented: showShare) {
                if let image = shareImage { ShareSheet(activityItems: [image]) }
                else if let url = shareURL { ShareSheet(activityItems: [url]) }
            }
            .fullScreenCover(isPresented: showEditOnboarding) { QuizView() }
    }
    
    func profileOverlays(showMedia: Binding<Bool>, achievements: [Achievement], index: Int) -> some View {
        self.fullScreenCover(isPresented: showMedia) {
            AchievementMediaViewer(achievements: achievements, startIndex: index)
        }
    }
    
    func profileConfirmations(showDelete: Binding<Bool>, showReset: Binding<Bool>, achievement: Achievement?, deleteAction: @escaping () -> Void, resetAction: @escaping () -> Void) -> some View {
        self
            .confirmationDialog("Delete Achievement?", isPresented: showDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { deleteAction() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This action cannot be undone.") }
            .alert("Reset All Data?", isPresented: showReset) {
                Button("Reset", role: .destructive) { resetAction() }
                Button("Cancel", role: .cancel) { }
            } message: { Text("This will permanently delete everything. You cannot undo this.") }
    }
    
    func profileLifecycle(selectedPhoto: Binding<PhotosPickerItem?>, profileImage: Binding<Image?>, achievementCount: Int, appearIndex: Binding<Int>) -> some View {
        self
            .onAppear { appearIndex.wrappedValue = achievementCount }
            .onChange(of: selectedPhoto.wrappedValue) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                        profileImage.wrappedValue = Image(uiImage: uiImage)
                    }
                }
            }
    }
}
