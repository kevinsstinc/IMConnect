//
//  IdeaIncubatorView.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 7/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct IdeaIncubatorView: View {
    @State private var polls: [Poll] = []
    @State private var showCreateSheet = false
    @State private var pulse = false
    @State private var selectedPoll: Poll? = nil
    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 31/255, blue: 91/255),
                        Color(red: 100/255, green: 42/255, blue: 122/255)
                    ]),
                    startPoint: pulse ? .topLeading : .bottomTrailing,
                    endPoint: pulse ? .bottomTrailing : .topLeading
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)
                .ignoresSafeArea()
                .onAppear {
                    pulse = true
                    listenToPolls()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack {
                            Text("Idea Incubator")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                showCreateSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 28)

                        VStack(spacing: 18) {
                            ForEach(polls) { poll in
                                PollCardView(poll: poll) { selectedIndex in
                                    voteOnPoll(poll, optionIndex: selectedIndex)
                                }
                                .onTapGesture {
                                    selectedPoll = poll
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 36)
                        .padding(.bottom, 100)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: IdeaChatbotView()) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.purple)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding()
                        .padding(.bottom, 70)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreatePollView {
                    showCreateSheet = false
                }
            }
            .sheet(item: $selectedPoll) { poll in
                PollDetailView(poll: poll)
            }
        }
    }

    func listenToPolls() {
        db.collection("idea_polls")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                polls = docs.map { Poll(from: $0.data(), id: $0.documentID) }
            }
    }

    func voteOnPoll(_ poll: Poll, optionIndex: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pollRef = db.collection("idea_polls").document(poll.pollId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let snapshot = try transaction.getDocument(pollRef)
                var votes = snapshot.data()?["votes"] as? [String: Int] ?? [:]
                var votedBy = snapshot.data()?["votedBy"] as? [String: Int] ?? [:]

                if let previousVote = votedBy[uid] {
                    if previousVote == optionIndex {
                        let prevKey = String(previousVote)
                        votes[prevKey] = max((votes[prevKey] ?? 1) - 1, 0)
                        votedBy.removeValue(forKey: uid)
                    } else {
                        let prevKey = String(previousVote)
                        votes[prevKey] = max((votes[prevKey] ?? 1) - 1, 0)
                        let key = String(optionIndex)
                        votes[key] = (votes[key] ?? 0) + 1
                        votedBy[uid] = optionIndex
                    }
                } else {
                    let key = String(optionIndex)
                    votes[key] = (votes[key] ?? 0) + 1
                    votedBy[uid] = optionIndex
                }

                transaction.updateData([
                    "votes": votes,
                    "votedBy": votedBy
                ], forDocument: pollRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                print("Transaction failed: \(error.localizedDescription)")
                return nil
            }
            return nil
        }, completion: { (object, error) in
            if let error = error {
                print("Transaction error: \(error.localizedDescription)")
            }
        })
    }
}
