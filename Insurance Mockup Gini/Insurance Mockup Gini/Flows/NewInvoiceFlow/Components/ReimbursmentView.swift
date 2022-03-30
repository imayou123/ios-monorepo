//
//  ReimbursmentView.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 29.03.2022.
//

import SwiftUI

struct ReinbursmentStatusView: View {
    var reimbursmentStatus: ReimbursmentState
    var price: Double

    var body: some View {
        VStack {
            HStack {
                Text("Reimbursement")
                    .font(Style.appFont(style: .semiBold, 14))
                Spacer()
                ReinbursmentInfoView(reimbursmentState: reimbursmentStatus)
            }.padding([.top, .leading, .trailing])

            HStack {
                Text("Date of reimbursement")
                    .font(Style.appFont(14))
                    .foregroundColor(.gray)
                Spacer()
                Text(reimbursmentStatus == .reimbursed ? "\(Date().getFormattedDate(format: "dd MMMM, yyyy"))" : "-")
                    .foregroundColor(.gray)
            }.padding([.top, .leading, .trailing])

            if reimbursmentStatus == .reimbursed {
                HStack {
                    Text("Reimbursed amount")
                        .font(Style.appFont(14))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(String(format: "%.2f", price * 0.25)) EUR (25%)")
                }.padding([.top, .leading, .trailing])
            }
        }
    }
}
