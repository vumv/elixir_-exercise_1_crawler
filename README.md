" Viết một chương trình elixir đơn giản crawl danh sách các phim (bao gồm tất cả các paging) của danh mục
    https://phimmoii.net/the-loai/hoat-hinh.html

    Danh sách các phim sau đó được lưu thành 1 file json với định dạng
    json
    {
      crawled_at: <thời gian crawl>,
      total: <tống số phim>,
      items: [
        {
          title: """",
          link: """",
          full_series: <true|false>, # đã hết bộ chưa
          number_of_episode: x, # tổng số tập đã phát hành
          thumnail: """", # link hình thumnail
          year: x, # năm đăng lên website
        }
      ]
    }
Sử dụng thư viện: https://github.com/philss/floki để parse html"\

Note: Hiện tại trang "https://phimmoii.net/the-loai/hoat-hinh.html" bên trên đã bị xoá không thể vào được
nên code đã thay thế bằng trang "https://vnphimmoi.com/phim-bo/"