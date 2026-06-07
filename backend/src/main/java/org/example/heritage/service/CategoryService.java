package org.example.heritage.service;

import org.example.heritage.pojo.dto.CategoryAddDTO;
import org.example.heritage.pojo.entity.HeritageCategory;

import java.util.List;

public interface CategoryService {

    List<HeritageCategory> listByPage(Integer page, Integer size);

    Long count();

    Integer add(CategoryAddDTO dto);

    void update(Integer categoryId, CategoryAddDTO dto);

    void delete(Integer categoryId);
}