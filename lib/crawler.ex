defmodule Crawler do
  use Crawly.Spider

  def run() do
    already_items = []
    url = "https://vnphimmoi.com/phim-bo/"
    start_page = 1
    recursive_parse_page(url, already_items, start_page)
  end

  def recursive_parse_page(in_page_url, in_already_items, in_start_page) do

    # print the current url
    IO.puts in_page_url

    # run recurively until current page url = last page url
    if in_start_page != 0 && String.contains?(in_page_url , "http")  do


      # some website is aguard from ddos by maximum 20 requests/ seconds
      # below code is delay every 20 requests
      if Integer.mod(in_start_page, 20) === 0 do
        :timer.sleep(1000)
      end

      response = Crawly.fetch(in_page_url)
      {:ok, document} = Floki.parse_document(response.body)

      items = Floki.find(document, "a.movie-item")
        |> Enum.map(fn row ->
          {_, [_, {_, href}, {_, title}], [{_, _, [{_, _, thumb}, {_, _, meta}]}]} = row
          [{_, [_, {_, thumb_image}], _}] = thumb
          [_, image, _] = String.split(thumb_image, "'")
          {_, _, meta_episode} = List.last(meta)
          meta_episode_info = List.last(meta_episode)
          episode_is_tuple = is_tuple(meta_episode_info)

          episode_info_text =
            if episode_is_tuple do
              Tuple.to_list(meta_episode_info) |> List.last() |> List.last()
            else
              meta_episode_info
            end

          current_episode = "0"
          number_of_episode = 0
          full_series = String.contains?(String.downcase(episode_info_text), "full ")

          if !full_series do
            episode_parts = String.split(episode_info_text, "/")

            if Enum.count(episode_parts) === 2 do
              [left, right] = episode_parts
              current_episode = String.split(String.trim(left, " "), " ") |> List.last()
              last_episode = String.split(String.trim(right, " "), " ") |> List.first()

              if last_episode === last_episode do
                full_series = true
              end
            end
          end

          current_episode = String.split(String.trim(episode_info_text, " "), " ") |> Enum.at(1)

          number_of_episode =
            case Integer.parse(current_episode) do
              {episode_value, ""} -> episode_value
              _ -> 0
            end

          %{
            title: title |> String.trim("\t") |> String.trim("\n"),
            link: href,
            thumbnail: image,
            number_of_episode: number_of_episode,
            full_series: full_series,
            reading_page: in_start_page
          }
        end)

      in_already_items = in_already_items ++ items

      [{_, _, pagination}] = Floki.find(document, "ul.pagination")
      {_, _, [{_, [_, {_, next_page_url}], _}]} = List.last(pagination)

      if in_page_url === next_page_url || String.contains?(next_page_url , "http")!==true do
        in_start_page = 0
      else
        in_start_page = in_start_page + 1
      end

      # loop with url = ext_page_url
      recursive_parse_page(next_page_url, in_already_items, in_start_page)
    else
      # end for getting data recursively
      out_items = %{
        crawled_at: to_string(DateTime.utc_now()),
        total: Enum.count(in_already_items),
        items: in_already_items
      }

      {status, result} = JSON.encode(out_items)

      file_path = Path.expand("../../../lib/result_data.json")
      File.write(file_path, result)

      IO.puts "OK, data is saved to file: " <> file_path
    end
  end
end
