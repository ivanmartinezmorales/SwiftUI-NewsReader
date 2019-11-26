//
//  ListArticlesView.swift
//  NewsReader
//
//  Created by Basem Emara on 2019-11-20.
//

import SwiftUI
import NewsCore

struct ListArticlesView: View {
    @ObservedObject var state: ListArticlesState

    let dispatch: Dispatcher<ListArticlesAction>
    let composer: ListArticlesComposer?
    
    var body: some View {
        List(state.articles) { article in
            NavigationLink(destination: self.composer?.showArticle(for: article)) {
                Text(article.title).font(.body)
            }
        }
        .navigationBarTitle(Text("News"))
        .navigationBarItems(trailing:
            Button(
                action: {
                    self.state.articles.isEmpty
                        ? self.dispatch(.loadArticles)
                        : self.dispatch(.clearArticles)
                },
                label: {
                    Text(self.state.articles.isEmpty ? "Load" : "Clear").font(.body)
                }
            )
        ).onAppear {
            self.dispatch(.loadArticles)
        }
    }
}

#if DEBUG
struct ListArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListArticlesView(
                state: ListArticlesState(
                    articles: [
                        Article(
                            url: "http://example.com/1",
                            title: "Example article 1",
                            content: "This is a test content for 1.",
                            excerpt: "This is a test excecrpt",
                            image: nil,
                            author: nil,
                            publishedAt: Date(),
                            source: ArticleSource(
                                id: "google-news",
                                name: "Google News"
                            )
                        ),
                        Article(
                            url: "http://example.com/2",
                            title: "Example article 2",
                            content: "This is a test content for 1.",
                            excerpt: "This is a test excecrpt",
                            image: nil,
                            author: nil,
                            publishedAt: Date(),
                            source: ArticleSource(
                                id: "google-news",
                                name: "Google News"
                            )
                        ),
                        Article(
                            url: "http://example.com/3",
                            title: "Example article 3",
                            content: "This is a test content for 1.",
                            excerpt: "This is a test excecrpt",
                            image: nil,
                            author: nil,
                            publishedAt: Date(),
                            source: ArticleSource(
                                id: "google-news",
                                name: "Google News"
                            )
                        )
                    ]
                ),
                dispatch: { _ in },
                composer: nil
            )
        }
    }
}
#endif
