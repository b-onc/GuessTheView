import UIKit

public class YoutubeGame: UIView {
    
    private enum State {
        case ready, playing, end
    }
    
    private var state: State = .ready {
        didSet {
            stateChanged(to: state)
        }
    }
    
    private let videoItems: [VideoItem]
    
    private let leftVideoThumbnail = UIButton(type: .custom)
    private let leftVideoViewCountLabel = UILabel()
    private let leftVideoTitleLabel = UILabel()
    private let rightVideoThumbnail = UIButton(type: .custom)
    private let rightVideoTitleLabel = UILabel()
    private let rightVideoViewCountLabel = UILabel()
    private let gameNameLabel = UILabel()
    private let gameStartButton = UIButton(type: .system)
    private let scoreLabel = UILabel()
    private let highScoreLabel = UILabel()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    
    private var gameSubviews: [UIView]
    private var readyScreenSubviews: [UIView]
    private var playingScreenSubviews: [UIView]
    private var answerSubviews: [UIView]
    private var endScreenSubviews: [UIView]
    
    private var rightVideoItem: VideoItem?
    private var leftVideoItem: VideoItem?
    
    private var highScore = 0 {
        didSet {
            highScoreLabel.text = "Highscore: \(highScore)"
        }
    }
    
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    public init() {
        
        if let jsonPath = Bundle.main.path(forResource: "videos", ofType: "json") {
            videoItems = Parser.parsePage(page: URL(fileURLWithPath: jsonPath))
        } else {
            fatalError("VideoItems can't be parsed")
        }
        
        readyScreenSubviews = [gameNameLabel, gameStartButton, highScoreLabel]
        playingScreenSubviews = [scoreLabel, leftVideoThumbnail, leftVideoTitleLabel,
                                 rightVideoThumbnail, rightVideoTitleLabel, questionLabel]
        answerSubviews = [leftVideoViewCountLabel, rightVideoViewCountLabel, answerLabel]
        endScreenSubviews = []
        gameSubviews = readyScreenSubviews + playingScreenSubviews + answerSubviews + endScreenSubviews
        super.init(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        
        gameSubviews.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        hideAllGameSubviews()
        
        gameNameLabel.text = "Can you guess the view count?"
        gameNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        gameNameLabel.sizeToFit()
        
        gameStartButton.setTitle("Start", for: .normal)
        gameStartButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
        
        highScore = 0
        highScoreLabel.sizeToFit()
        
        // Setup ready screen
        NSLayoutConstraint.activate([
            gameNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            gameNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            gameStartButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            gameStartButton.topAnchor.constraint(equalTo: gameNameLabel.bottomAnchor, constant: 20),
            
            highScoreLabel.topAnchor.constraint(equalTo: gameStartButton.bottomAnchor, constant: 20),
            highScoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        
        rightVideoThumbnail.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)
        leftVideoThumbnail.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)
        
        rightVideoThumbnail.layer.cornerRadius = 10
        rightVideoThumbnail.clipsToBounds = true
        
        leftVideoThumbnail.layer.cornerRadius = 10
        leftVideoThumbnail.clipsToBounds = true
        
        questionLabel.text = "Which one do you think got more views on Youtube?"
        questionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        questionLabel.sizeToFit()
        
        score = 0
        scoreLabel.sizeToFit()
        
        answerLabel.text = "Placeholder\nText"
        answerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        answerLabel.sizeToFit()
        
        rightVideoTitleLabel.text = "Placeholder\nText"
        rightVideoTitleLabel.lineBreakMode = .byWordWrapping
        rightVideoTitleLabel.numberOfLines = 0
        
        rightVideoViewCountLabel.text = "0"
        rightVideoViewCountLabel.sizeToFit()
        
        leftVideoTitleLabel.text = "Placeholder\nText"
        leftVideoTitleLabel.lineBreakMode = .byWordWrapping
        leftVideoTitleLabel.numberOfLines = 0
        
        leftVideoViewCountLabel.text = "0"
        leftVideoViewCountLabel.sizeToFit()
        
        // Setup game screen
        NSLayoutConstraint.activate([
            questionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            
            rightVideoTitleLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            rightVideoTitleLabel.widthAnchor.constraint(equalToConstant: 240),
            rightVideoTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            rightVideoThumbnail.centerXAnchor.constraint(equalTo: rightVideoTitleLabel.centerXAnchor),
            rightVideoThumbnail.widthAnchor.constraint(equalToConstant: 240),
            rightVideoThumbnail.heightAnchor.constraint(equalToConstant: 180),
            rightVideoThumbnail.topAnchor.constraint(equalTo: rightVideoTitleLabel.bottomAnchor, constant: 40),
            
            rightVideoViewCountLabel.topAnchor.constraint(equalTo: rightVideoThumbnail.bottomAnchor, constant: 10),
            rightVideoViewCountLabel.widthAnchor.constraint(equalToConstant: 240),
            rightVideoViewCountLabel.centerXAnchor.constraint(equalTo: rightVideoThumbnail.centerXAnchor),
            
            leftVideoTitleLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            leftVideoTitleLabel.widthAnchor.constraint(equalToConstant: 240),
            leftVideoTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            leftVideoThumbnail.centerXAnchor.constraint(equalTo: leftVideoTitleLabel.centerXAnchor),
            leftVideoThumbnail.widthAnchor.constraint(equalToConstant: 240),
            leftVideoThumbnail.heightAnchor.constraint(equalToConstant: 180),
            leftVideoThumbnail.centerYAnchor.constraint(equalTo: rightVideoThumbnail.centerYAnchor),
            
            leftVideoViewCountLabel.topAnchor.constraint(equalTo: leftVideoThumbnail.bottomAnchor, constant: 10),
            leftVideoViewCountLabel.widthAnchor.constraint(equalToConstant: 240),
            leftVideoViewCountLabel.centerXAnchor.constraint(equalTo: leftVideoThumbnail.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: leftVideoViewCountLabel.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            answerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            answerLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20)
            ])
        
        state = .ready
        
    }
    
    @objc func thumbnailTapped(_ sender: UIButton) {
        let leftWins = isWinnerImageLeft()
        if (sender == leftVideoThumbnail && leftWins) || (sender == rightVideoThumbnail && !leftWins) {
            score += 1
            answerLabel.text = "Correct! ✅"
            answerLabel.textColor = UIColor.green
            animateIn(views: answerSubviews) { (_) -> (Void) in
                Thread.sleep(forTimeInterval: 1)
                self.showImages()
            }
        } else {
            answerLabel.text = "Wrong! ❌"
            answerLabel.textColor = UIColor.red
            animateIn(views: answerSubviews) { (_) -> (Void) in
                Thread.sleep(forTimeInterval: 1)
                self.state = .end
            }
        }
    }
    
    private func isWinnerImageLeft() -> Bool {
        return (leftVideoItem?.views ?? 0 > rightVideoItem?.views ?? 0)
    }
    
    @objc func startButtonTapped(_ sender: UIButton) {
        state = .playing
    }
    
    private func hideAllGameSubviews() {
        gameSubviews.forEach {
            $0.isHidden = true
            $0.alpha = 0
        }
    }
    
    private func animateIn(views: [UIView], completion: ((Bool) -> (Void))?) {
        views.forEach { view in
            view.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 1
            }, completion: completion)
        }
    }
    
    private func areItemsFinished() -> Bool {
        var unusedItemCount = 0
        videoItems.forEach { if !$0.itemUsed { unusedItemCount += 1 } }
        return unusedItemCount < 2
    }
    
    private func showImages() {
        answerSubviews.forEach {
            $0.isHidden = true
            $0.alpha = 0
        }
        if areItemsFinished() {
            self.videoItems.forEach { $0.itemUsed = false }
        }
        let getRN: () -> (Int) = {
            return Int(arc4random_uniform(UInt32(self.videoItems.count)))
        }
        var rightNumber = getRN()
        while videoItems[rightNumber].itemUsed {
            rightNumber = getRN()
        }
        var leftNumber = getRN()
        while rightNumber == leftNumber || videoItems[leftNumber].itemUsed {
            leftNumber = getRN()
        }
        rightVideoItem = videoItems[rightNumber]
        leftVideoItem = videoItems[leftNumber]
        rightVideoItem?.itemUsed = true
        leftVideoItem?.itemUsed = true
        rightVideoThumbnail.setImage(rightVideoItem?.thumbnailImage, for: .normal)
        leftVideoThumbnail.setImage(leftVideoItem?.thumbnailImage, for: .normal)
        rightVideoTitleLabel.text = rightVideoItem?.title
        leftVideoTitleLabel.text = leftVideoItem?.title
        rightVideoViewCountLabel.text = "\(NumberFormatter.localizedString(from: NSNumber(value: rightVideoItem?.views ?? 0), number: NumberFormatter.Style.decimal)) views"
        leftVideoViewCountLabel.text = "\(NumberFormatter.localizedString(from: NSNumber(value: leftVideoItem?.views ?? 0), number: NumberFormatter.Style.decimal)) views"
    }
    
    private func stateChanged(to: State) {
        hideAllGameSubviews()
        switch state {
        case .ready:
            animateIn(views: readyScreenSubviews, completion: nil)
        case .playing:
            showImages()
            animateIn(views: playingScreenSubviews, completion: nil)
        case .end:
            if score > highScore { highScore = score }
            score = 0
            self.videoItems.forEach { $0.itemUsed = false }
            self.state = .ready
        }
    }
}
