# UIKitPaginationDemo

## Overview

UIKitPaginationDemo is an iOS application built using Swift and UIKit, showcasing efficient handling of paginated data fetching and display in a collection view. The app integrates with a remote API (https://gorest.co.in) to fetch user data and dynamically load more content as the user scrolls.

## Features

- **Efficient Pagination:** Implements a smooth infinite scrolling experience using a PaginationManager to manage API requests.
- **MVVM Architecture:** Separates concerns into View, ViewModel, and Model layers for better maintainability.
- **Networking with URLSession:** Handles API requests and responses, including error handling and decoding.
- **Loading Indicators:** Displays loading states while fetching data.
- **Custom UICollectionViewCell:** Renders user data with a clean and responsive UI.

## Directory Structure
```Python
UIKitPaginationDemo/
│── Assets.xcassets/               # App assets (icons, colors)
│── Base.lproj/                    # Storyboard files
│── Extensions/                    # Utility extensions for Data and URLRequest
│── Network/                       # Networking layer
│   ├── Endpoints/                 # API endpoint definitions
│   ├── APIAgent.swift             # Core networking agent
│   ├── Endpoint.swift             # Protocols and definitions
│   ├── LoadingIndicator.swift     # Loading indicator UI
│   ├── Media.swift                # Media handling
│   ├── Pagination.swift           # Pagination logic
│── Source/
│   ├── UserList/
│   │   ├── Cell/                  # Custom collection view cell
│   │   ├── Model/                 # User model
│   │   ├── ViewController/        # ViewController implementation
│   │   ├── ViewModel/             # ViewModel for managing data
│── AppDelegate.swift              # App lifecycle management
│── SceneDelegate.swift            # Scene lifecycle management
│── Info.plist                     # Application configuration
```

## Installation & Setup

### Prerequisites

- Xcode 14 or later
- iOS 14+ target device/simulator
- Swift 5.0+

### Steps to Run the Project

1. Clone the repository:

```bash
git clone https://github.com/your-repo/UIKitPaginationDemo.git
cd UIKitPaginationDemo
```

2. Open the project in Xcode:
```bash
open UIKitPaginationDemo.xcodeproj
```
3. Build and run the project using an iOS simulator or a physical device.

## Usage

### Fetching Users with Pagination

- The app starts by fetching the first page of user data.
- As the user scrolls down, additional pages are requested dynamically.
- A loading indicator appears while fetching data.
- Error handling ensures the app provides feedback if data retrieval fails.

### API Integration

The `UserEndpoint.swift` defines the API endpoints:
```Swift
enum UserEndpoint: EndPoint {
    case getUsers(page: Int)
    
    var baseURL: URL {
        return URL(string: "https://gorest.co.in")!
    }

    var path: String {
        return "public/v2/users"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        switch self {
        case .getUsers(let page):
            return ["page": page, "per_page": 20]
        }
    }

    var task: NetworkTask {
        return .requestParameters
    }
}
```
## Handling API Requests

The `APIAgent.swift` handles network requests and responses:
```Swift
APIAgent.shared.run(UserEndpoint.getUsers(page: 1)) { (result: APIResult<User>) in
    switch result {
    case .success(let response):
        print("Fetched Users: \(response?.data ?? [])")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

## Collection View Integration

The `UserListViewController.swift` updates the UI with fetched users:
```Swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath
    ) as? UserCollectionViewCell else {
        return UICollectionViewCell()
    }
    let user = viewModel.users[indexPath.row]
    cell.configure(with: user)
    return cell
}
```

## Contributions

Feel free to submit pull requests or report issues to improve this project.

## License

This project is licensed under the MIT License.
