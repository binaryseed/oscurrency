module ReqsHelper
  def accepted_message(req)
    bid = req.accepted_bid
    accepted_time = time_ago_in_words(bid.accepted_at)
    "Accepted bid from #{person_link bid.person} at #{accepted_time} ago"
  end

  def commitment_message(req)
    bid = req.committed_bid
    commitment_time = time_ago_in_words(bid.committed_at)
    if req.isoffer
      "Commitment by #{person_link req.person} made #{commitment_time} ago"
    else
      "Commitment by #{person_link bid.person} made #{commitment_time} ago"
    end
  end

  def completed_message(req)
    bid = req.committed_bid
    completed_time = time_ago_in_words(bid.completed_at)
    if req.isoffer
      "Marked completed by #{person_link req.person} #{completed_time} ago"
    else
      "Marked completed by #{person_link bid.person} #{completed_time} ago"
    end
  end

  def approved_message(req)
    bid = req.committed_bid
    approved_time = time_ago_in_words(bid.approved_at)
    if req.isoffer
      "Confirmed completed by #{person_link bid.person} #{approved_time} ago"
    else
      "Confirmed completed by #{person_link bid.req.person} #{approved_time} ago"
    end
  end
  
  
  
  def bid_accepted_message(bid)
    accepted_time = time_ago_in_words(bid.accepted_at)
    "Bid Accepted #{accepted_time} ago"
  end

  def bid_commitment_message(bid)
    commitment_time = time_ago_in_words(bid.committed_at)
    if bid.req.isoffer
      "Commitment by #{person_link bid.req.person} made #{commitment_time} ago"
    else
      "Commitment by #{person_link bid.person} made #{commitment_time} ago"
    end
  end

  def bid_completed_message(bid)
    completed_time = time_ago_in_words(bid.completed_at)
    if bid.req.isoffer
      "Marked completed by #{person_link bid.req.person} #{completed_time} ago"
    else
      "Marked completed by #{person_link bid.person} #{completed_time} ago"
    end
  end

  def bid_approved_message(bid)
    approved_time = time_ago_in_words(bid.approved_at)
    if bid.req.isoffer
      "Confirmed completed by #{person_link bid.person} #{approved_time} ago"
    else
      "Confirmed completed by #{person_link bid.req.person} #{approved_time} ago"
    end
  end
  
  
end
