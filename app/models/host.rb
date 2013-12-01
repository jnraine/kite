class Host < User
  has_many :venues, :dependent => :destroy
  has_many :events, :through => :venues

  make_flaggable :unsubscribe
end